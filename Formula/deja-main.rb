class DejaMain < Formula
  desc "Predictive inline shell autosuggestions for zsh (tracks main)"
  homepage "https://github.com/Serubin/deja"
  license "MIT"

  # Tracks the tip of main rather than a release tarball, so this is a HEAD-only
  # formula:
  #
  #   brew install --HEAD serubin/tools/deja-main
  #   brew upgrade --fetch-HEAD serubin/tools/deja-main
  #
  # A tarball would need a sha256 that changes on every push, and pinning a
  # revision would mean bumping the formula by hand to pick anything up.
  #
  # Named deja-main, not deja, so it does not collide with the upstream
  # giammarco-ferranti/deja/deja formula — Homebrew will not install two
  # formulae of the same name from different taps.
  head "https://github.com/Serubin/deja.git", branch: "main"

  depends_on "go" => :build

  # All three install a `deja` binary into the same prefix.
  conflicts_with "deja-canary", because: "both install a `deja` binary"
  conflicts_with "giammarco-ferranti/deja/deja", because: "both install a `deja` binary"

  def install
    revision = Utils.git_head(safe: true) || "unknown"
    revision = revision[0, 7]

    ldflags = %W[
      -s -w
      -X main.version=main-#{revision}
      -X main.commit=#{revision}
      -X main.date=#{time.iso8601}
    ]

    # CGO is required: the SQLite driver is mattn/go-sqlite3.
    ENV["CGO_ENABLED"] = "1"
    # output: is explicit because std_go_args names the binary after the
    # formula, which would install `deja-main`/`deja-canary`. The command is
    # `deja`, and the two formulae are deliberately mutually exclusive: they
    # share ~/.local/share/deja, and deja bakes the absolute path of the binary
    # that generated init.zsh into it, so two installed copies would each see
    # the other's stamp as stale and regenerate the script on every shell.
    system "go", "build", *std_go_args(ldflags: ldflags, output: bin/"deja"), "./cmd/deja"
  end

  def caveats
    <<~EOS
      Import your existing zsh history once:

        deja import

      Then add this to your ~/.zshrc:

        if [[ -r "$HOME/.local/share/deja/init.zsh" ]]; then
          source "$HOME/.local/share/deja/init.zsh"
        else
          eval "$(deja init zsh)"
        fi

      Sourcing the cached script keeps deja off your shell startup path; the
      eval is only the first-run bootstrap.

      The daemon outlives shell sessions, so after upgrading replace it with:

        deja daemon --restart
    EOS
  end

  test do
    assert_match "deja", shell_output("#{bin}/deja version")

    # An end-to-end exercise of the real paths: import a history file, then ask
    # for a suggestion. This runs with the daemon down, so it covers the direct
    # SQLite fallback rather than just argument parsing.
    ENV["HOME"] = testpath
    (testpath/"history").write <<~EOS
      : 1700000001:0;git status
      : 1700000002:0;git commit --amend
    EOS

    system bin/"deja", "import", "--file", testpath/"history"
    assert_match "git commit --amend",
      shell_output("#{bin}/deja query --buffer 'git com' --dir #{testpath}")
  end
end
