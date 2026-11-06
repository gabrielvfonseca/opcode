# Managing Opcode in an organization

Administrators can turn Opcode features off on managed Macs with a configuration
profile. Served at https://anoma.ly/opcode/docs/admin.

These keys are **macOS only**. Windows reads only `DisableUpdates` (a DWORD
under `HKLM` or `HKCU\SOFTWARE\Policies\Anomaly\Opcode`), and Linux reads none.

## Keys

All keys are Booleans in the `anomaly.opcode` preference domain. A key counts only
when a configuration profile forces it (`CFPreferencesAppValueIsForced`), so a
value someone writes with `defaults write` locks nothing. Opcode reads them at
launch; a changed profile applies after Opcode relaunches.

| Key | Effect |
| --- | --- |
| `DisableMeetings` | No meeting detection, recording, transcription, or notes. Meetings recorded before stay readable with `opcode meetings` and `opcode mcp`. |
| `DisableAnnotate` | Annotate (captures) is off. |
| `DisableOpenCodeProcessing` | No OpenCode requests: mode rewrites, meeting notes and titles, and sending captures to OpenCode sessions. |
| `DisableTransforms` | No transforms at all, built in or from `opcode.config.ts`; the config is never loaded. |
| `RestrictTransformsToLoopback` | Transforms stay on, but `fetch` reaches only this Mac and `node:child_process` (`exec`, `execFile`) is refused. Every host name, redirects included, must resolve to loopback addresses only (`127.0.0.0/8`, `::1`); the check runs on the resolved addresses Opcode connects to, and the system proxy is bypassed. Use it with a local, authenticated model proxy. |
| `DisableLabs` | Every Labs feature is off. |
| `DisableUpdates` | Opcode never checks for, downloads, or installs updates. |

A locked feature reads as off everywhere: the window shows its setting off
and disabled with "Managed by your organization", and `opcode settings set`,
`opcode labs on`, the local API, shortcuts, and background work all refuse it.
Opcode never rewrites the person's own settings, so removing the profile brings
back what they had chosen.

## Sample profile

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>PayloadDisplayName</key>
  <string>Opcode</string>
  <key>PayloadIdentifier</key>
  <string>com.example.opcode</string>
  <key>PayloadType</key>
  <string>Configuration</string>
  <key>PayloadUUID</key>
  <string>9A1C2E3F-0000-4000-8000-000000000001</string>
  <key>PayloadVersion</key>
  <integer>1</integer>
  <key>PayloadContent</key>
  <array>
    <dict>
      <key>PayloadType</key>
      <string>anomaly.opcode</string>
      <key>PayloadIdentifier</key>
      <string>com.example.opcode.settings</string>
      <key>PayloadUUID</key>
      <string>9A1C2E3F-0000-4000-8000-000000000002</string>
      <key>PayloadVersion</key>
      <integer>1</integer>
      <key>DisableMeetings</key>
      <true/>
      <key>DisableOpenCodeProcessing</key>
      <true/>
      <key>RestrictTransformsToLoopback</key>
      <true/>
      <key>DisableLabs</key>
      <true/>
    </dict>
  </array>
</dict>
</plist>
```

Replace the identifiers and UUIDs with your own and leave out the keys you
don't need. Most MDM tools (Jamf, Kandji, Intune, Mosyle) accept the inner
dictionary as a custom settings payload for the `anomaly.opcode` domain.

To check what Opcode sees on a Mac: `opcode labs` lists Labs features as `managed`,
`opcode settings get meetings.enabled` reports it as not writable, and Opcode's
`process.log` names the locks at launch.
