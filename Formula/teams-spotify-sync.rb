class TeamsSpotifySync < Formula
  desc "Auto-adjust Spotify volume during Microsoft Teams meetings"
  homepage "https://github.com/Serubin/teams-spotify-sync"
  url "https://github.com/Serubin/teams-spotify-sync/archive/refs/tags/v1.1.1.tar.gz"
  sha256 "628888b2eeafba2f1bfc4d184433d4f9ae64195f381ea095e7e926d4ed53e77c"
  license "MIT"

  depends_on "jq"
  depends_on :macos

  def install
    bin.install "teams-spotify-sync"
  end

  def caveats
    <<~EOS
      To get started:
        teams-spotify-sync setup

      Required external tool (not managed by this formula):
        teams-monitor: dotnet tool install -g svrooij.teams-monitor

      To start automatically on login:
        teams-spotify-sync install

      To stop and remove:
        teams-spotify-sync uninstall
    EOS
  end

  test do
    assert_match "teams-spotify-sync v#{version}", shell_output("#{bin}/teams-spotify-sync version")
  end
end
