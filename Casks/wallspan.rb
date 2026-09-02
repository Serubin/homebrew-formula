cask "wallspan" do
  version "0.1.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/Serubin/WallSpan/releases/download/v#{version}/Wallspan-#{version}.zip"
  name "Wallspan"
  desc "Menu bar app for spanning one wallpaper across every display"
  homepage "https://github.com/Serubin/WallSpan"

  # No conflicts_with here: a cask's only valid key is :cask, so the collision with
  # Formula/wallspan.rb -- both link `wallspan` onto PATH -- cannot be declared from
  # either side. Homebrew refusing to overwrite the existing symlink is the whole
  # backstop, and the caveats below say so.
  #
  # Package.swift pins .macOS(.v14).
  depends_on macos: :sonoma

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

      brew install --cask --no-quarantine serubin/tap/wallspan

    or open it once, then allow it under System Settings > Privacy & Security.

    This links the bundled CLI onto your PATH, so it cannot be installed alongside
    the wallspan formula. Use one or the other.
  EOS
end
