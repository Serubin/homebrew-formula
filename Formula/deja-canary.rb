class DejaCanary < Formula
  desc "Predictive inline shell autosuggestions for zsh (canary branch)"
  homepage "https://github.com/Serubin/deja"
  license "MIT"

  # Tracks the tip of canary — unreleased work, ahead of main. HEAD-only for the
  # same reason as the `deja` formula: a branch that moves cannot be pinned to a
  # tarball checksum. Install with:
  #
  #   brew install --HEAD serubin/tools/deja-canary
  #
  # and pick up new commits with:
  #
  #   brew upgrade --fetch-HEAD serubin/tools/deja-canary
  head "https://github.com/Serubin/deja.git", branch: "canary"

  depends_on "go" => :build

  # All three install a `deja` binary into the same prefix.
  conflicts_with "deja-main", because: "both install a `deja` binary"
  conflicts_with "giammarco-ferranti/deja/deja", because: "both install a `deja` binary"

  def install
    revision = Utils.git_head(safe: true) || "unknown"
    revision = revision[0, 7]

    ldflags = %W[
      -s -w
      -X main.version=canary-#{revision}
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
      This is the canary build — unreleased work from the `canary` branch.
      It shares ~/.local/share/deja with the other deja formulae, including the
      history database, so switching between them keeps your history.

      Import your existing zsh history once:

        deja import

      Then add this to your ~/.zshrc:

        if [[ -r "$HOME/.local/share/deja/init.zsh" ]]; then
          source "$HOME/.local/share/deja/init.zsh"
        else
          eval "$(deja init zsh)"
        fi

      The daemon outlives shell sessions, so after installing or upgrading,
      replace the running one:

        deja daemon --restart

      Upgrading from a build that predates `--restart`, that command cannot
      identify the old daemon and will say so. Once only:

        pkill -f 'deja daemon'
    EOS
  end

  test do
    assert_match "deja", shell_output("#{bin}/deja version")

    ENV["HOME"] = testpath
    (testpath/"history").write <<~EOS
      : 1700000001:0;git status
      : 1700000002:0;git commit --amend
    EOS

    system bin/"deja", "import", "--file", testpath/"history"
    assert_match "git commit --amend",
      shell_output("#{bin}/deja query --buffer 'git com' --dir #{testpath}")

    # Canary carries the zsh/net/socket transport, so the generated integration
    # script must contain the socket path substitution and the zsocket probe.
    system bin/"deja", "init", "zsh"
    init_script = testpath/".local/share/deja/init.zsh"
    assert_path_exists init_script
    assert_match "zsocket", init_script.read
    refute_match "{{", init_script.read
  end
end
