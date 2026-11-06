#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
package="$root/sdk/service-darwin-arm64"
destination="$package/bin/opcode-service"

if [ "$(uname -s)" != "Darwin" ] || [ "$(uname -m)" != "arm64" ]; then
  echo "The current TypeScript SDK helper package targets arm64 macOS." >&2
  exit 1
fi

"$root/scripts/prepare-service-app.sh" >/dev/null
source="$root/target/Opcode Service.app/Contents/MacOS/opcode-service"
mkdir -p "$(dirname -- "$destination")"
cp "$source" "$destination"
chmod 755 "$destination"
codesign --verify --strict --verbose=2 "$destination"

echo "$destination"
