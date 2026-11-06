#!/bin/sh

# Sourced by the app and helper packagers. Print only the selected identity so
# callers can capture it without mixing diagnostics into codesign arguments.
opcode_codesign_identity() {
  team_id=$1
  identity=${OPCODE_CODESIGN_IDENTITY:-}
  if [ -z "$identity" ]; then
    identity=$(security find-identity -v -p codesigning | sed -n "s/.*\"\(Developer ID Application:.*($team_id)\)\"/\1/p" | head -1)
  fi
  if [ -z "$identity" ]; then
    echo "No Developer ID signing identity found for team $team_id. Set OPCODE_CODESIGN_IDENTITY." >&2
    return 1
  fi
  case "$identity" in
    "Developer ID Application:"*"($team_id)") ;;
    *)
      echo "Signing identity is not a Developer ID Application identity for team $team_id." >&2
      return 1
      ;;
  esac
  printf '%s\n' "$identity"
}

# Submit one artifact and wait. A local notarytool keychain profile wins;
# otherwise CI authenticates with an App Store Connect API key file.
opcode_notarize() {
  if [ -n "${OPCODE_NOTARY_PROFILE:-}" ]; then
    xcrun notarytool submit "$1" --keychain-profile "$OPCODE_NOTARY_PROFILE" --wait
  else
    xcrun notarytool submit "$1" \
      --key "${OPCODE_NOTARY_KEY:?Set OPCODE_NOTARY_PROFILE, or OPCODE_NOTARY_KEY with OPCODE_NOTARY_KEY_ID and OPCODE_NOTARY_ISSUER}" \
      --key-id "${OPCODE_NOTARY_KEY_ID:?Set OPCODE_NOTARY_KEY_ID to the App Store Connect API key ID}" \
      --issuer "${OPCODE_NOTARY_ISSUER:?Set OPCODE_NOTARY_ISSUER to the App Store Connect issuer ID}" \
      --wait
  fi
}

opcode_version() {
  printf '%s\n' "${OPCODE_VERSION:-$(cargo metadata --no-deps --format-version 1 --manifest-path "$1/Cargo.toml" | jq -r '.packages[] | select(.name == "opcode") | .version')}"
}

# CFBundleVersion: the run number of a dev build (0.0.0-dev-N), else from
# X.Y.Z (a prerelease shares its release's number). Opcode's updater compares
# neither; it follows the channel's current release.
opcode_build_number() {
  if [ -n "${OPCODE_BUILD_NUMBER:-}" ]; then
    printf '%s\n' "$OPCODE_BUILD_NUMBER"
    return
  fi
  case "$1" in
    0.0.0-dev-[0-9]*) printf '%s\n' "${1#0.0.0-dev-}" ;;
    *) printf '%s\n' "${1%%-*}" | awk -F. '{ print ($1 * 10000) + ($2 * 100) + $3 }' ;;
  esac
}
