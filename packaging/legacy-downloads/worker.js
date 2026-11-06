// Kit's old Opcode hosts, all redirected to anoma.ly:
// - downloads.opcode.kitlangton.dev and .com (the bucket Opcode 2.3.1 and earlier
//   read): every path, 302, to https://anoma.ly/opcode/files, where
//   opcode-production-files holds byte copies of everything they served and the
//   Legacy appcast workflow publishes.
// - opcode.kitlangton.com and .dev (the old website): 301 to https://anoma.ly/opcode,
//   with the download and installer paths kept working.
const WEBSITE = {
  "/download": "/opcode/download/macos-arm64-dmg",
  "/install-linux.sh": "/opcode/files/install-linux.sh",
  "/install-windows.ps1": "/opcode/files/install-windows.ps1",
}

export default {
  fetch(request) {
    const { hostname, pathname, search } = new URL(request.url)
    if (hostname.startsWith("downloads.")) {
      return Response.redirect(`https://anoma.ly/opcode/files${pathname}${search}`, 302)
    }
    const path = WEBSITE[pathname.replace(/\/+$/, "")] ?? "/opcode/"
    return Response.redirect(`https://anoma.ly${path}`, 301)
  },
}
