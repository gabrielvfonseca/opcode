#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
export OPCODE_TEAM_ID=TESTTEAM00
temporary=$(mktemp -d "${TMPDIR:-/tmp}/opcode-app-identity.XXXXXX")
trap 'rm -rf "$temporary"' EXIT HUP INT TERM
bundle="$temporary/Opcode.app"
mkdir -p "$bundle/Contents"
plist="$bundle/Contents/Info.plist"
cp "$root/app/Info.plist" "$plist"

[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$plist")" = anomaly.opcode ]
[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$plist")" = opcode ]
[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' "$plist")" = Opcode ]
[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleName' "$plist")" = Opcode ]

expect_rejection() {
  if output=$(sh "$root/scripts/validate-app.sh" "$bundle" Opcode.app 2.1.0 20100 2>&1); then
    echo "Unexpectedly accepted an incompatible app." >&2
    exit 1
  fi
  printf '%s\n' "$output" | grep -Fq "$1"
}

/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier com.kitlangton.Opcode' "$plist"
expect_rejection 'wrong bundle identifier'
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier com.kitlangton.opcode.agent' "$plist"
expect_rejection 'wrong bundle identifier'
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier ly.anoma.Opcode' "$plist"
expect_rejection 'wrong bundle identifier'
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier com.kitlangton.opcode2' "$plist"
expect_rejection 'wrong bundle identifier'
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier anomaly.opcode' "$plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleExecutable opcode-watch' "$plist"
expect_rejection 'wrong executable name'
/usr/libexec/PlistBuddy -c 'Set :CFBundleExecutable opcode' "$plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleShortVersionString 2.1.0' "$plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleVersion 20100' "$plist"
mkdir -p "$bundle/Contents/MacOS"
printf '#!/bin/sh\n' >"$bundle/Contents/MacOS/opcode"
chmod +x "$bundle/Contents/MacOS/opcode"
expect_rejection 'scrawl-helper is missing'

for script in build-app.sh build-service-app.sh release-app.sh; do
  if output=$(env -u OPCODE_TEAM_ID sh "$root/scripts/$script" 2>&1); then
    echo "Unexpectedly allowed $script without an explicit signing team." >&2
    exit 1
  fi
  printf '%s\n' "$output" | grep -Fq 'Set OPCODE_TEAM_ID to the Apple Developer signing team'
done

for script in build-app.sh build-service-app.sh; do
  for identity in 'Developer ID Application: Fixture (WRONGTEAM0)' 'Apple Development: Fixture (TESTTEAM00)'; do
    if output=$(OPCODE_CODESIGN_IDENTITY="$identity" sh "$root/scripts/$script" 2>&1); then
      echo "Unexpectedly allowed an incompatible signing identity in $script." >&2
      exit 1
    fi
    printf '%s\n' "$output" | grep -Fq 'Signing identity is not a Developer ID Application identity for team TESTTEAM00'
  done
done

if output=$(env -u OPCODE_NOTARY_PROFILE sh "$root/scripts/prepare-service-app.sh" 2>&1); then
  echo "Unexpectedly allowed helper notarization without an explicit profile." >&2
  exit 1
fi
printf '%s\n' "$output" | grep -Fq 'Set OPCODE_NOTARY_PROFILE to the matching notarization profile'

echo "Rust app identity guards passed."
