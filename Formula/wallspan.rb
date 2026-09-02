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

  # Builds the tip of main from source. CI's snapshot builds are upload-artifact uploads,
  # which need a token to fetch and expire after 90 days, so there is no prebuilt artifact
  # for `--HEAD` to install and no revision for `--fetch-HEAD` to compare:
  #
  #   brew install --HEAD serubin/formula/wallspan
  #   brew upgrade --fetch-HEAD serubin/formula/wallspan
  head do
    url "https://github.com/Serubin/WallSpan.git", branch: "main"
    # Package.swift declares swift-tools-version:5.9.
    depends_on xcode: ["15.0", :build]
  end

  depends_on macos: :sonoma

  def install
    if build.head?
      # --disable-sandbox: SwiftPM's own sandbox collides with the one Homebrew already
      # runs the build in. Native arch only — the universal build exists for distribution
      # and would double compile time here for nothing.
      system "swift", "build", "--disable-sandbox", "-c", "release"
      bin.install ".build/release/wallspan"
    else
      bin.install "wallspan"
    end
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
    output = shell_output("#{bin}/wallspan version")
    assert_match(/^wallspan \d+\.\d+\.\d+/, output)
    # A HEAD build reports whatever the source tree claims, while the formula's version is
    # the literal "HEAD", so only a stable install can be held to a matching number.
    assert_match "wallspan #{version}", output unless head?

    # `info` is the one command that needs a display, so it is not something a test machine
    # can be held to. These two are what the project's own CI smoke step runs.
    system bin/"wallspan", "help"
    system bin/"wallspan", "config", "show"
  end
end
