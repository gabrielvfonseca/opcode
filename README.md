# Opcode

Opcode is local voice dictation for Mac, Windows and Linux. Hold a key, speak, and
it pastes.

## How it works

- hold the shortcut, speak, then let go
- Opcode transcribes on your device and pastes into whatever app you're in
- the first run downloads a speech model; after that nothing leaves your machine
- experimental features live in Labs, at the bottom of the sidebar

## Downloads

Stable is the current release. Dev is the newest build of `dev` and updates
itself from the dev channel.

| Platform | Stable | Dev |
| --- | --- | --- |
| macOS (Apple silicon) | [DMG](https://anoma.ly/opcode/download/macos-arm64-dmg) | [DMG](https://anoma.ly/opcode/download/dev/macos-arm64-dmg) |
| Windows x64 | [Installer](https://anoma.ly/opcode/download/windows-x64-setup) | [Installer](https://anoma.ly/opcode/download/dev/windows-x64-setup) |
| Windows ARM64 | [Installer](https://anoma.ly/opcode/download/windows-arm64-setup) | [Installer](https://anoma.ly/opcode/download/dev/windows-arm64-setup) |
| Linux x86_64 | [Executable](https://anoma.ly/opcode/download/linux-x64) | [Executable](https://anoma.ly/opcode/download/dev/linux-x64) |
| Linux x86_64 (Debian, Ubuntu) | [.deb](https://anoma.ly/opcode/download/linux-x64-deb) | [.deb](https://anoma.ly/opcode/download/dev/linux-x64-deb) |
| Linux x86_64 (Fedora, openSUSE) | [.rpm](https://anoma.ly/opcode/download/linux-x64-rpm) | [.rpm](https://anoma.ly/opcode/download/dev/linux-x64-rpm) |
| Linux ARM64 | [Executable](https://anoma.ly/opcode/download/linux-arm64) | [Executable](https://anoma.ly/opcode/download/dev/linux-arm64) |
| Linux ARM64 (Debian, Ubuntu) | [.deb](https://anoma.ly/opcode/download/linux-arm64-deb) | [.deb](https://anoma.ly/opcode/download/dev/linux-arm64-deb) |
| Linux ARM64 (Fedora, openSUSE) | [.rpm](https://anoma.ly/opcode/download/linux-arm64-rpm) | [.rpm](https://anoma.ly/opcode/download/dev/linux-arm64-rpm) |

Or install with:

- Homebrew: `brew install --cask anomalyco/tap/opcode`
- AUR: `yay -S opcode-bin`
- install script (Linux): `curl -fsSL https://anoma.ly/opcode/install-linux.sh | sh`
- Nix: `nix profile add github:anomalyco/opcode`

More docs are in [`docs/`](docs/README.md).

## Contributing

We don't take pull requests. [Open an issue](https://github.com/anomalyco/opcode/issues)
describing the bug or idea, and our agents usually turn it around fast.

MIT licensed.
