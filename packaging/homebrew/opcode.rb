cask "opcode" do
  version "@VERSION@"
  sha256 "@SHA256@"

  url "@URL@"
  name "Opcode"
  desc "Local voice dictation"
  homepage "https://anoma.ly/opcode/"

  livecheck do
    url "https://anoma.ly/release/opcode/desktop/stable.json"
    strategy :json do |json|
      json.dig("release", "version")
    end
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "Opcode.app"

  uninstall quit: "anomaly.opcode"

  zap trash: [
    "~/.config/opcode",
    "~/Library/Application Support/opcode",
    "~/Library/Caches/anomaly.opcode",
    "~/Library/HTTPStorages/anomaly.opcode",
    "~/Library/Preferences/anomaly.opcode.plist",
    "~/Library/Saved Application State/anomaly.opcode.savedState",
  ]
end
