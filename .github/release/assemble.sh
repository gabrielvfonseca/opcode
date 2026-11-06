#!/usr/bin/env bash
# assemble.sh <in> <dist>: gathers the release files from the verified
# artifacts in <in>/<name>/ into <dist>, refusing any file that is not one of
# the release service targets for OPCODE_VERSION (docs/plans/release-service.md)
# or that two artifacts both hold.
. "$(dirname "$0")/lib.sh"

in=$(posix "$1")
dist=$(posix "$2")
v=$OPCODE_VERSION
mkdir -p "$dist"
for file in "$in"/*/*; do
  name=$(basename "$file")
  [ "$name" = SHA256SUMS ] && continue
  case "$name" in
    "opcode-$v-linux-x64" | "opcode-$v-linux-x64.deb" | "opcode-$v-linux-x64.rpm" | \
      "opcode-$v-linux-arm64" | "opcode-$v-linux-arm64.deb" | "opcode-$v-linux-arm64.rpm" | \
      "opcode-$v-macos-arm64.zip" | "opcode-$v-macos-arm64.dmg" | \
      "opcode-$v-windows-x64.exe" | "opcode-$v-windows-arm64.exe" | \
      "opcode-$v-windows-x64.com" | "opcode-$v-windows-arm64.com" | \
      "opcode-setup-$v-windows-x64.exe" | "opcode-setup-$v-windows-arm64.exe") ;;
    *) die "$name is not a release file of Hex $v." ;;
  esac
  [ ! -e "$dist/$name" ] || die "Two artifacts hold $name."
  cp "$file" "$dist/$name"
done
(cd "$dist" && ls -l && sha256 -- *) | tee -a "${GITHUB_STEP_SUMMARY:-/dev/null}"
