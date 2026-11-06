#!/usr/bin/env bash
# sign-macos.sh <unsigned Opcode.app zip> <out dir>: signs Opcode.app inside-out
# with the Developer ID identity (hardened runtime, secure timestamp, Opcode's
# entitlements), notarizes and staples it, then writes the release service's
# two macOS targets from the stapled app: opcode-<version>-macos-arm64.zip (root
# Opcode.app, for the updater) and opcode-<version>-macos-arm64.dmg (signed,
# notarized, stapled, with an Applications link). The app is data here: it is
# never launched. The DMG's window comes from dmg-background.tiff and
# dmg-DS_Store beside the zip (packaging/macos/dmg), also data: they are
# checked by magic number and size and copied in for Finder to read.
#
# Environment: OPCODE_VERSION, OPCODE_SIGNING_IDENTITY, OPCODE_KEYCHAIN, OPCODE_NOTARY_KEY,
# OPCODE_NOTARY_KEY_ID, OPCODE_NOTARY_ISSUER (macos-credentials.sh).
. "$(dirname "$0")/lib.sh"

input=$1
out=$2
release=$(cd "$(dirname "$0")" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$out"
zip="$out/opcode-$OPCODE_VERSION-macos-arm64.zip"
dmg="$out/opcode-$OPCODE_VERSION-macos-arm64.dmg"

/usr/bin/ditto -x -k "$input" "$work/unpacked"
app="$work/unpacked/Opcode.app"
if [ ! -d "$app" ] || [ "$(find "$work/unpacked" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')" != 1 ]; then
  die "The macOS build must hold exactly Opcode.app."
fi
[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Contents/Info.plist")" = anomaly.opcode ] ||
  die "Opcode.app has the wrong bundle identifier."
[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Contents/Info.plist")" = "$OPCODE_VERSION" ] ||
  die "Opcode.app is not version $OPCODE_VERSION."

layout=$(dirname "$input")
background="$layout/dmg-background.tiff"
finder="$layout/dmg-DS_Store"
check_layout() { # <file> <magic numbers in hex>...
  file=$1
  shift
  { [ -f "$file" ] && [ ! -L "$file" ]; } || die "The macOS build lacks $(basename "$file")."
  [ "$(wc -c < "$file")" -le 4194304 ] || die "$(basename "$file") is over 4 MiB."
  for magic in "$@"; do
    [ "$(head -c $((${#magic} / 2)) "$file" | xxd -p)" = "$magic" ] && return
  done
  die "$(basename "$file") is not the file type it should be."
}
check_layout "$background" 4d4d002a 49492a00
check_layout "$finder" 0000000142756431

# Every Mach-O in the bundle must be one this script signs: these always,
# and libonnxruntime only while a build still bundles it.
required=$(printf '%s\n' Contents/MacOS/opcode Contents/MacOS/scrawl-helper \
  Contents/Library/OpcodeMicrophone.driver/Contents/MacOS/OpcodeMicrophoneDriver | LC_ALL=C sort)
optional=Contents/Frameworks/libonnxruntime.1.23.2.dylib
found=$(cd "$app" && find . -type f -exec sh -c 'file -b "$1" | grep -q Mach-O && printf "%s\n" "${1#./}"' _ {} \; | LC_ALL=C sort)
expected=$required
if printf '%s\n' "$found" | grep -qxF "$optional"; then
  expected=$(printf '%s\n%s\n' "$required" "$optional" | LC_ALL=C sort)
fi
[ "$found" = "$expected" ] || die "Unexpected code in Opcode.app: $(diff <(echo "$expected") <(echo "$found") | grep '^[<>]' | tr '\n' ' ')"

sign() {
  codesign --force --timestamp --options runtime --keychain "$OPCODE_KEYCHAIN" --sign "$OPCODE_SIGNING_IDENTITY" "$@"
}
notarize() {
  xcrun notarytool submit "$1" --key "$OPCODE_NOTARY_KEY" --key-id "$OPCODE_NOTARY_KEY_ID" --issuer "$OPCODE_NOTARY_ISSUER" --wait --timeout 45m
}

if [ -f "$app/$optional" ]; then sign "$app/$optional"; fi
sign "$app/Contents/Library/OpcodeMicrophone.driver"
# The capture experiment's movie decoder; Opcode runs it, so it needs no entitlement.
sign --identifier anomaly.opcode.scrawl-helper "$app/Contents/MacOS/scrawl-helper"
sign --entitlements "$release/opcode.entitlements" "$app"
codesign --verify --deep --strict --verbose=2 "$app"

# Notarize the app first so its ticket is stapled inside both targets.
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$app" "$work/notarize.zip"
notarize "$work/notarize.zip"
xcrun stapler staple "$app"
xcrun stapler validate "$app"

rm -f "$zip" "$dmg"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$app" "$zip"

mkdir "$work/staging"
/usr/bin/ditto "$app" "$work/staging/Opcode.app"
ln -s /Applications "$work/staging/Applications"
cp "$background" "$work/staging/.background.tiff"
cp "$finder" "$work/staging/.DS_Store"
# hdiutil on the hosted runners intermittently fails (Resource busy).
for attempt in 1 2 3 4 5; do
  hdiutil create -fs APFS -format ULFO -volname Opcode -srcfolder "$work/staging" "$dmg" && break
  [ "$attempt" -lt 5 ] || exit 1
  echo "hdiutil create failed (attempt $attempt); retrying" >&2
  rm -f "$dmg"
  sleep 10
done
codesign --force --timestamp --keychain "$OPCODE_KEYCHAIN" --sign "$OPCODE_SIGNING_IDENTITY" "$dmg"
notarize "$dmg"
xcrun stapler staple "$dmg"
xcrun stapler validate "$dmg"
ls -l "$out"
