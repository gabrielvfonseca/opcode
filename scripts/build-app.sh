#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$root/scripts/macos-signing.sh"
# OPCODE_TEST_BUILD=1 builds the CI test app: ad-hoc signed, under its own
# name and bundle ID so it installs beside the released Opcode and never
# touches its permissions; it never checks for updates.
# OPCODE_LOCAL_BUILD=1 marks a build made from a checkout for its owner's own
# machine (Developer ID signed as usual): it shows "Local build · updates off"
# with its commit and never checks for or offers updates.
# OPCODE_RELEASE_UNSIGNED=1 builds the release app (Opcode, anomaly.opcode) ad-hoc
# signed: the Release workflow's build job, which holds no credentials. Its
# sign-macos job signs it with the Developer ID (.github/release/sign-macos.sh).
if [ "${OPCODE_RELEASE_UNSIGNED:-}" = 1 ]; then
  team_id=
  identity=-
  app_name=Opcode
  bundle_id=anomaly.opcode
elif [ "${OPCODE_TEST_BUILD:-}" = 1 ]; then
  team_id=
  identity=-
  app_name="Opcode Test"
  bundle_id=anomaly.opcode.test
else
  team_id=${OPCODE_TEAM_ID:?Set OPCODE_TEAM_ID to the Apple Developer signing team}
  identity=$(opcode_codesign_identity "$team_id")
  app_name=Opcode
  bundle_id=anomaly.opcode
fi
# Every build carries the `capture` experiment (dormant until enabled), with
# Scrawl's `scrawl-helper` beside `opcode`, where the engine looks for it.
# crates/capture/build.rs compiles the helper from crates/capture/helper into
# target/release.
icon_output="$root/target/AppIcon.assets"
icon_info="$root/target/AppIcon-info.plist"
version=$(opcode_version "$root")
build_number=$(opcode_build_number "$version")
bundle_name="$app_name.app"
executable_name=opcode

bundle="$root/target/app/$bundle_name"
executable="$bundle/Contents/MacOS/$executable_name"

sign() {
  if [ "$identity" = - ]; then
    codesign --force --sign - "$@"
  else
    codesign --force --timestamp --options runtime --sign "$identity" "$@"
  fi
}

export MACOSX_DEPLOYMENT_TARGET=15.0
# Cargo may run through a wrapper that does not forward the environment (Kit's
# HiveMind-backed cargo), so build-time variables also travel as --config.
env_args=()
if [ -z "${OPCODE_COMMIT:-}" ] && { [ "${OPCODE_LOCAL_BUILD:-}" = 1 ] || [ "${OPCODE_TEST_BUILD:-}" = 1 ]; }; then
  OPCODE_COMMIT=$(git -C "$root" rev-parse --short=7 HEAD 2>/dev/null || true)
fi
for name in OPCODE_LOCAL_BUILD OPCODE_TEST_BUILD OPCODE_COMMIT OPCODE_BUILD_CHANNEL; do
  value=${!name:-}
  if [ -n "$value" ]; then
    case "$value" in
      *\'*) echo "$name must not contain a single quote" >&2; exit 1 ;;
    esac
    env_args+=(--config "env.$name='$value'")
  fi
done
# The helper's embedded Info.plist names Opcode, not Scrawl.
SCRAWL_HELPER_PLIST="$root/packaging/macos/scrawl-helper-Info.plist" \
  cargo build --locked --release ${env_args[@]+"${env_args[@]}"} --manifest-path "$root/Cargo.toml"
rm -rf "$bundle"
mkdir -p "$bundle/Contents/MacOS" "$bundle/Contents/Resources" "$bundle/Contents/Library"
cp "$root/target/release/opcode" "$executable"
cp "$root/target/release/scrawl-helper" "$bundle/Contents/MacOS/scrawl-helper"
cp "$root/app/Info.plist" "$bundle/Contents/Info.plist"
cp "$root/LICENSE" "$root/THIRD_PARTY_NOTICES.md" "$bundle/Contents/Resources/"
OPCODE_VERSION="$version" OPCODE_BUILD_NUMBER="$build_number" OPCODE_TEAM_ID="$team_id" OPCODE_CODESIGN_IDENTITY="${identity#-}" OPCODE_SKIP_INSTALL_SCRIPT=1 \
  "$root/scripts/build-opcode-microphone-driver.sh" "$bundle/Contents/Library" >&2
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $version" "$bundle/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $build_number" "$bundle/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $bundle_id" "$bundle/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable $executable_name" "$bundle/Contents/Info.plist"
plutil -replace CFBundleName -string "$app_name" "$bundle/Contents/Info.plist"
plutil -replace CFBundleDisplayName -string "$app_name" "$bundle/Contents/Info.plist"
# Links into the playground (src/rune_ui/story_link.rs); a test build's own
# scheme never opens the installed Opcode.
url_scheme=opcode
[ "${OPCODE_TEST_BUILD:-}" = 1 ] && url_scheme=opcode-test
/usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLName $bundle_id" "$bundle/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 $url_scheme" "$bundle/Contents/Info.plist"
# The helper mirrors a cabled iPhone as a camera; macOS asks on Opcode's behalf.
plutil -replace NSCameraUsageDescription -string "Opcode mirrors and records a cabled iPhone's screen for a capture." "$bundle/Contents/Info.plist"
rm -rf "$icon_output"
mkdir -p "$icon_output"
xcrun actool "$root/app/AppIcon.icon" \
  --compile "$icon_output" \
  --platform macosx \
  --minimum-deployment-target 15.0 \
  --app-icon AppIcon \
  --standalone-icon-behavior all \
  --output-partial-info-plist "$icon_info" \
  --output-format human-readable-text \
  --warnings \
  --notices >&2
cp "$icon_output/AppIcon.icns" "$icon_output/Assets.car" "$bundle/Contents/Resources/"

sign "$bundle/Contents/Library/OpcodeMicrophone.driver"
# Opcode runs it only to decode the capture's movie, which needs no
# entitlement; anything it touches is attributed to Opcode, its responsible
# process.
sign --identifier "$bundle_id.scrawl-helper" "$bundle/Contents/MacOS/scrawl-helper"
sign --entitlements "$root/.github/release/opcode.entitlements" "$bundle"
codesign --verify --deep --strict --verbose=2 "$bundle"
echo "$bundle"
