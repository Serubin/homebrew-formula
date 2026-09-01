# homebrew-formula

Personal Homebrew tap.

```
brew tap serubin/formula
```

| Formula | |
|---|---|
| `deja` | Predictive inline shell autosuggestions for zsh, built from the `canary` branch |
| `wallspan` | The wallspan CLI on its own |
| `teams-spotify-sync` | Auto-adjust Spotify volume during Microsoft Teams meetings |

| Cask | |
|---|---|
| `wallspan` | Wallspan.app, the menu bar app, which bundles the CLI |

```
brew install serubin/formula/deja
brew install --cask --no-quarantine serubin/formula/wallspan
```

The wallspan cask and formula are alternatives, not companions — both claim `wallspan` on
your PATH, so install one or the other. The cask needs `--no-quarantine` because the app is
ad-hoc signed rather than notarised; without it macOS blocks the first launch until you
allow the app under System Settings > Privacy & Security.

`deja` shares a name with the upstream `giammarco-ferranti/deja/deja`, so use the
fully-qualified name if you have both taps.

Formerly `serubin/tools`. GitHub redirects the old repository name, but re-tap anyway:

```
brew untap serubin/tools
brew tap serubin/formula
```
