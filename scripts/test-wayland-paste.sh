#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == --inside ]]; then
  target=
  keyboard=
  service=
  finish() {
    status=$?
    trap - EXIT
    if [[ -n "$target" ]]; then kill "$target" 2>/dev/null || true; fi
    if [[ -n "$keyboard" ]]; then kill "$keyboard" 2>/dev/null || true; fi
    if [[ -n "$service" ]]; then kill "$service" 2>/dev/null || true; wait "$service" 2>/dev/null || true; fi
    printf '%s\n' "$status" > "$OPCODE_WAYLAND_TEST_RESULT"
    swaymsg exit >/dev/null 2>&1 || true
    exit "$status"
  }
  trap finish EXIT

  # Seed the isolated compositor's keyboard state before any window exists,
  # and keep Ctrl and Alt held on it as a user still holding a shortcut would:
  # wtype's own keyboard must paste plain Ctrl+V without waiting for them.
  wtype -k v -M ctrl -M alt -p VoidSymbol -s 60000 &
  keyboard=$!
  for ((attempt = 0; attempt < 100; attempt++)); do
    if swaymsg -t get_inputs -r | grep -q wlr_virtual_keyboard; then break; fi
    sleep 0.05
  done
  "$OPCODE_WAYLAND_TEST_TARGET" "$OPCODE_WAYLAND_PASTE_OUTPUT" &
  target=$!
  for ((attempt = 0; attempt < 100; attempt++)); do
    if [[ -f "$OPCODE_WAYLAND_PASTE_OUTPUT.ready" ]]; then break; fi
    sleep 0.05
  done
  test -f "$OPCODE_WAYLAND_PASTE_OUTPUT.ready"
  "$OPCODE_WAYLAND_TEST_BINARY" --exact linux::paste::tests::native_wayland_clipboard_shortcut \
    --ignored --nocapture --test-threads=1
  kill "$target"
  wait "$target" 2>/dev/null || true
  target=

  # The app-window check uses compositor IPC, not keyboard input. Remove the
  # synthetic seat first rather than expose a transient, keymap-less keyboard.
  kill "$keyboard"
  wait "$keyboard" 2>/dev/null || true
  keyboard=
  for ((attempt = 0; attempt < 100; attempt++)); do
    if ! swaymsg -t get_inputs -r | grep wlr_virtual_keyboard >/dev/null; then break; fi
    sleep 0.05
  done
  "$OPCODE_WAYLAND_APP_BINARY" service >"$OPCODE_WAYLAND_APP_LOG.service" 2>&1 &
  service=$!
  for ((attempt = 0; attempt < 100; attempt++)); do
    if "$OPCODE_WAYLAND_APP_BINARY" status >/dev/null 2>&1; then break; fi
    sleep 0.05
  done
  "$OPCODE_WAYLAND_APP_BINARY" status >/dev/null
  # A second launch forwards Activate to the running Opcode and exits; the
  # window opens in the service's own process.
  open_window() {
    "$OPCODE_WAYLAND_APP_BINARY" app >>"$OPCODE_WAYLAND_APP_LOG" 2>&1
    for ((attempt = 0; attempt < 200; attempt++)); do
      kill -0 "$service"
      if swaymsg -t get_tree -r | grep '"name": "Opcode"' >/dev/null; then break; fi
      sleep 0.05
    done
    swaymsg -t get_tree -r | grep '"name": "Opcode"' >/dev/null
    swaymsg -t get_tree -r | grep "\"pid\": $service," >/dev/null
    swaymsg -t get_tree -r | grep '"app_id": "anomaly.opcode"' >/dev/null
  }
  open_window
  # Keep the window connected while the paste helper creates a virtual keyboard.
  export OPCODE_WAYLAND_PASTE_OUTPUT="$OPCODE_WAYLAND_PASTE_OUTPUT-coexist"
  "$OPCODE_WAYLAND_TEST_TARGET" "$OPCODE_WAYLAND_PASTE_OUTPUT" &
  target=$!
  for ((attempt = 0; attempt < 100; attempt++)); do
    if swaymsg -t get_tree -r | grep '"name": "Opcode Wayland Test"' >/dev/null; then break; fi
    sleep 0.05
  done
  swaymsg -t get_tree -r | grep '"name": "Opcode Wayland Test"' >/dev/null
  wtype -p v -p VoidSymbol -s 60000 &
  keyboard=$!
  for ((attempt = 0; attempt < 100; attempt++)); do
    if [[ -f "$OPCODE_WAYLAND_PASTE_OUTPUT.ready" ]]; then break; fi
    sleep 0.05
  done
  test -f "$OPCODE_WAYLAND_PASTE_OUTPUT.ready"
  "$OPCODE_WAYLAND_TEST_BINARY" --exact linux::paste::tests::native_wayland_clipboard_shortcut \
    --ignored --nocapture --test-threads=1
  kill -0 "$service"
  kill "$target"
  wait "$target" 2>/dev/null || true
  target=

  # Closing the window keeps Opcode; a later launch opens it again.
  swaymsg '[app_id="anomaly.opcode"] kill' >/dev/null
  for ((attempt = 0; attempt < 100; attempt++)); do
    if ! swaymsg -t get_tree -r | grep '"name": "Opcode"' >/dev/null; then break; fi
    sleep 0.05
  done
  if swaymsg -t get_tree -r | grep '"name": "Opcode"' >/dev/null; then
    echo "The Opcode window did not close." >&2
    exit 1
  fi
  sleep 0.5
  kill -0 "$service"
  "$OPCODE_WAYLAND_APP_BINARY" status >/dev/null
  if [[ "${OPCODE_WAYLAND_REOPEN:-1}" == 1 ]]; then
    open_window
  fi
  "$OPCODE_WAYLAND_APP_BINARY" quit
  wait "$service"
  service=
  exit 0
fi

if [[ $# != 2 || $(id -u) == 0 ]]; then
  echo "Usage: $0 /path/to/compiled-test /path/to/opcode (run as an unprivileged user)" >&2
  exit 1
fi
for command in cc pkg-config sway swaymsg wtype wl-copy wl-paste dbus-run-session timeout; do
  command -v "$command" >/dev/null
done
root=$(cd -- "$(dirname -- "$0")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
export OPCODE_WAYLAND_TEST_BINARY
OPCODE_WAYLAND_TEST_BINARY=$(realpath -- "$1")
export OPCODE_WAYLAND_APP_BINARY
OPCODE_WAYLAND_APP_BINARY=$(realpath -- "$2")
export OPCODE_WAYLAND_TEST_SCRIPT="$root/scripts/test-wayland-paste.sh"
export OPCODE_WAYLAND_TEST_TARGET="$work/target"
export OPCODE_WAYLAND_PASTE_OUTPUT="$work/pasted.txt"
export OPCODE_WAYLAND_TEST_RESULT="$work/result"
export OPCODE_WAYLAND_APP_LOG="$work/opcode.log"
export XDG_RUNTIME_DIR="$work/runtime"
export XDG_DATA_HOME="$work/data"
export XDG_CONFIG_HOME="$work/config"
export OPCODE_APPLICATION_SUPPORT_DIR="$work/support"
export ALSA_CONFIG_PATH="$work/alsa.conf"
printf '# No physical audio devices in this fixture.\n' > "$ALSA_CONFIG_PATH"
mkdir -m 700 "$XDG_RUNTIME_DIR"
cc "$root/tests/fixtures/wayland-paste-target.c" $(pkg-config --cflags --libs gtk+-3.0) -o "$OPCODE_WAYLAND_TEST_TARGET"
unset DISPLAY WAYLAND_DISPLAY SWAYSOCK
# Hardware Vulkan drivers need a GPU renderer (WLR_RENDERER=gles2) to share
# surfaces with the compositor; Mesa's software driver works with pixman.
export WLR_BACKENDS=headless WLR_RENDERER=${WLR_RENDERER:-pixman} WLR_LIBINPUT_NO_DEVICES=1 GDK_BACKEND=wayland
if ! timeout 25 dbus-run-session -- sway --config "$root/tests/fixtures/wayland-paste.conf" >"$work/compositor.log" 2>&1 \
  || [[ ! -f "$work/result" || $(<"$work/result") != 0 ]]; then
  cat "$work/compositor.log"
  if [[ -f "$work/opcode.log" ]]; then cat "$work/opcode.log"; fi
  if [[ -f "$work/opcode.log.service" ]]; then cat "$work/opcode.log.service"; fi
  exit 1
fi
echo "Native Wayland clipboard insertion, clipboard restoration, and the single-process window checks passed."
