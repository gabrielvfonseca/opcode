#!/bin/sh
# Mirrors another Mac's Opcode meetings folder for a local, read-only `opcode mcp
# --meetings-dir`. One rsync over SSH; audio (*.wav), lock, and temporary
# files stay behind. Updated files land together at the end of the transfer
# (--delay-updates), and meetings trashed on the source disappear here.
#
# Exits quietly when the source is asleep or unreachable, so a LaunchAgent can
# run it every few minutes. The mirror and its meeting folders stay owner-only. See scripts/launchd/opcode-meetings-mirror.plist.
#
# Environment:
#   OPCODE_MEETINGS_HOST    SSH host (default: pro)
#   OPCODE_MEETINGS_SOURCE  folder on the host, relative to its home
#                        (default: Library/Application Support/opcode/meetings)
#   OPCODE_MEETINGS_MIRROR  local mirror (default: ~/Library/Caches/opcode-meetings-mirror)
set -eu

host=${OPCODE_MEETINGS_HOST:-pro}
source_dir=${OPCODE_MEETINGS_SOURCE:-Library/Application Support/opcode/meetings}
mirror=${OPCODE_MEETINGS_MIRROR:-$HOME/Library/Caches/opcode-meetings-mirror}

mkdir -p "$mirror"
chmod 700 "$mirror"

# The remote shell splits the path, so escape its spaces.
remote_path=$(printf '%s/' "${source_dir%/}" | sed 's/ /\\ /g')
errors=$(mktemp "${TMPDIR:-/tmp}/opcode-meetings-mirror.XXXXXX")
trap 'rm -f "$errors"' EXIT

status=0
rsync -a --delete --delete-delay --delay-updates --timeout=60 \
	--exclude='*.wav' --exclude='*.lock' --exclude='*.tmp' --exclude='.DS_Store' \
	-e 'ssh -o BatchMode=yes -o ConnectTimeout=5 -o ServerAliveInterval=10 -o ServerAliveCountMax=2' \
	"$host:$remote_path" "$mirror/" 2>"$errors" || status=$?

# rsync -a copies the source folder's mode onto the mirror root.
chmod 700 "$mirror"
if [ "$status" -eq 0 ]; then
	exit 0
fi
# 255 from ssh, or a connection-level rsync failure: the host is asleep,
# offline, or refused the connection. Try again on the next run.
if [ "$status" -eq 255 ] || grep -qiE 'connect|timed out|timeout|refused|unreachable|no route|resolve|broken pipe|reset by peer|closed' "$errors"; then
	exit 0
fi
cat "$errors" >&2
exit "$status"
