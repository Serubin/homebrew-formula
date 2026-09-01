# typed: false
# frozen_string_literal: true

# The CLI alone, from the universal tarball the release workflow builds. The menu bar app
# lives in Casks/wallspan.rb and bundles its own copy of this binary, so the two deliberately
# collide on `bin/wallspan` rather than being installed side by side.
class Wallspan < Formula
  desc "CLI for spanning one wallpaper across every display"
  homepage "https://github.com/Serubin/WallSpan"
  url "https://github.com/Serubin/WallSpan/releases/download/v0.1.0/wallspan-0.1.0-universal.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "GPL-3.0-or-later"

  depends_on macos: :sonoma

  def install
    bin.install "wallspan"
  end

  def caveats
    <<~EOS
      This is the CLI alone. The menu bar app, which bundles the same binary, is:

        brew install --cask serubin/formula/wallspan

      They both claim `wallspan` on your PATH, so install one or the other.
    EOS
  end

  test do
    # On the release channel `version` prints "wallspan X.Y.Z  (json schema N)"; other
    # channels name the channel first, which is why this matches a prefix rather than a line.
    assert_match "wallspan #{version}", shell_output("#{bin}/wallspan version")

    # `info` is the one command that needs a display, so it is not something a test machine
    # can be held to. These two are what the project's own CI smoke step runs.
    system bin/"wallspan", "help"
    system bin/"wallspan", "config", "show"
  end
end
