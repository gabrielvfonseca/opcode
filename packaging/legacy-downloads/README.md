# Legacy redirects (Kit's account)

One Worker, `opcode-legacy-downloads`, takes over Kit's four old Opcode hosts:

```ts
downloads.opcode.kitlangton.dev/*, .com/*   302 → https://anoma.ly/opcode/files<path><query>   (Opcode ≤ 2.3.1 feeds, appcast, files)
opcode.kitlangton.dev/*, .com/*             301 → https://anoma.ly/opcode/
  /download                                  → https://anoma.ly/opcode/download/macos-arm64-dmg
  /install-linux.sh, /install-windows.ps1    → https://anoma.ly/opcode/files/<same name>
```

The downloads hosts get Worker routes, which run in front of the
`opcode-releases` bucket's custom domains, so the bucket keeps its domains. The
website hosts become Custom Domains of this Worker, taken over from the
`opcode-voice-site` Worker (a hostname has one Worker). Deploy from the
repository root with Kit's Wrangler login:

```sh
bunx wrangler@latest deploy --config packaging/legacy-downloads/wrangler.jsonc
```

Wrangler asks before moving a hostname from `opcode-voice-site`; answer yes. If
it refuses instead (for example because `opcode-voice-site` serves the hosts by
routes, not custom domains), remove `opcode-voice-site`'s domains and routes in
the dashboard (Workers & Pages → opcode-voice-site → Settings → Domains &
Routes) and deploy again. Nothing is deleted: the bucket and
`opcode-voice-site` stay as they are.

Roll back with `bunx wrangler@latest delete --config
packaging/legacy-downloads/wrangler.jsonc`, then reattach `opcode.kitlangton.com` and `.dev` to
`opcode-voice-site` in the dashboard (the downloads hosts fall back to the
bucket by themselves) (the bytes there never
changed, so old installs see exactly what they did before).
