# Test Builds

Every push to `dev` runs the [Test builds](https://github.com/anomalyco/opcode/actions/workflows/test-builds.yml)
workflow (`.github/workflows/test-builds.yml`; run it by hand with **Run
workflow**). Open the latest green run: its summary links each download.
Artifacts are kept 14 days, and downloading one requires a GitHub login with
access to the repository.

```ts
opcode-test-<commit>-macos-arm64       // opcode-test-<commit>-arm64.dmg
opcode-test-<commit>-windows-x86_64    // opcode-setup-<version>-windows-x64.exe + bare opcode-<version>-windows-x64.exe
opcode-test-<commit>-windows-aarch64   // opcode-setup-<version>-windows-arm64.exe + bare opcode-<version>-windows-arm64.exe
opcode-test-<commit>-linux-x86_64      // opcode-<version>-linux-x64
```

None of these are code-signed, notarized, or published. They never update
themselves, so the signed release cannot replace the build you are testing.
GitHub wraps each artifact in a zip; unzip it first.

## macOS (Apple silicon, macOS 15 or later)

The test app is **Opcode Test.app** (bundle ID `anomaly.opcode.test`),
ad-hoc signed and never checks for updates. Its own name and bundle ID let it sit
beside a released `Opcode.app` without touching that app's permissions, login
item, or updates. It also keeps its own data: settings, models, History, and
meetings live in `~/Library/Application Support/opcode-test`, personal commands in
`~/.config/opcode-test`, and meeting Markdown in `~/Documents/Opcode Test Meetings`,
so it starts with onboarding and never reads or changes the installed Opcode's
data. Both apps listen to the same shortcut and microphone, so run one at a
time.

1. Quit Opcode from its menu-bar icon.
2. Open the DMG and drag **Opcode Test** to Applications.
3. Clear the download quarantine, which macOS otherwise reports as an app that
   cannot be opened or is damaged:

   ```sh
   xattr -dr com.apple.quarantine "/Applications/Opcode Test.app"
   ```

   Alternatively, open it once, then choose **Open Anyway** in System Settings →
   Privacy & Security.
4. Open Opcode Test and grant Microphone and Accessibility again. Ad-hoc
   signatures change with every build, so each new test build needs these
   grants again: remove the old **Opcode Test** entries in System Settings and
   add the new app.

To go back, quit Opcode Test, delete it, and open Opcode.

## Windows (10 or 11, x64 or ARM64)

The installer and executable are unsigned, so SmartScreen warns: choose **More
info**, then **Run anyway**.

1. Quit Opcode from its tray icon.
2. Run `opcode-setup-<version>-windows-<x64|arm64>.exe`. It replaces an installed Opcode of
   the same or an older version in the usual per-user layout, and refuses to
   replace a newer one: uninstall that first from Apps & Features (settings are
   kept). Or skip the installer and run the bare `opcode-<version>-windows-<arch>.exe` from any folder.
3. The test build never self-updates. To return to the release, run the
   release installer from <https://anoma.ly/opcode>.

## Linux (x86_64)

An installed Opcode starts through its systemd user unit, so launching the test
binary normally would just start the installed one. Run the test binary as the
instance directly instead:

```sh
opcode quit
chmod +x opcode-*-linux-x64
./opcode-*-linux-x64 service     # runs Opcode in the foreground; Ctrl-C quits
./opcode-*-linux-x64             # in another terminal: opens the window
```

After Ctrl-C, `opcode` starts the installed Opcode again.

## Reporting

Include the commit from the artifact name, the OS and architecture, and the
logs: `~/Library/Application Support/opcode/logs/` on macOS,
`%APPDATA%\opcode\logs\` on Windows, and
`~/.local/share/opcode/logs/` on Linux.
