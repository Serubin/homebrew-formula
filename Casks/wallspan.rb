cask "wallspan" do
  version "0.1.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/Serubin/WallSpan/releases/download/v#{version}/Wallspan-#{version}.zip",
      verified: "github.com/Serubin/WallSpan/"
  name "Wallspan"
  desc "Menu bar app for spanning one wallpaper across every display"
  homepage "https://github.com/Serubin/WallSpan"

  # Not enforced by Homebrew today, but the collision below is real: both artifacts claim
  # `wallspan` on PATH, and the link step is what actually refuses.
  conflicts_with formula: "wallspan"
  # Package.swift pins .macOS(.v14).
  depends_on macos: ">= :sonoma"

  app "Wallspan.app"
  # The app bundles the CLI and prefers whichever `wallspan` is on PATH, so linking its own
  # copy is what keeps the two from drifting to different builds.
  binary "#{appdir}/Wallspan.app/Contents/Helpers/wallspan"

  uninstall launchctl: "net.serubin.wallspan",
            quit:      "net.serubin.wallspan.app"

  zap trash: [
    "~/Library/Application Support/wallspan",
    "~/Library/LaunchAgents/net.serubin.wallspan.plist",
    "~/Library/Logs/wallspan.log",
    "~/Library/Preferences/net.serubin.wallspan.app.plist",
  ]

  caveats <<~EOS
    Wallspan is ad-hoc signed and not notarised, and Homebrew quarantines the apps it
    installs, so macOS blocks the first launch. Either install it with

      brew install --cask --no-quarantine serubin/formula/wallspan

    or open it once, then allow it under System Settings > Privacy & Security.
  EOS
end
