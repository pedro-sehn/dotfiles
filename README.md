# dotfiles

macOS (Apple Silicon) developer environment. Configs live here, symlinked into place.

Neovim config is **not** in this repo — it lives in its own repository.

## Layout

| Path | Symlink target |
|---|---|
| `aerospace/.aerospace.toml` | `~/.aerospace.toml` |
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/.zprofile` | `~/.zprofile` |
| `zsh/.zshenv` | `~/.zshenv` |
| `git/.gitconfig` | `~/.gitconfig` |
| `git/ignore` | `~/.config/git/ignore` |
| `asdf/.tool-versions` | `~/.tool-versions` |
| `opencode/opencode.jsonc` | `~/.config/opencode/opencode.jsonc` |
| `opencode/package.json` | `~/.config/opencode/package.json` |
| `claude/settings.json` | `~/.claude/settings.json` |
| `touchbar-app/config.json` | `~/.config/touchbar-app/config.json` |
| `Brewfile` | — (`brew bundle`) |

## Bootstrap

```sh
# 1. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Trust the third-party tap that ships lazy-click
brew trust kappke/tap

# 3. Everything else (formulae, casks, VS Code extensions, npm globals)
brew bundle --file=Brewfile

# 4. Oh My Zsh (not managed by brew)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"

# 5. Rust (installs ~/.cargo/env, sourced from .zshenv)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 6. Language runtimes via asdf
asdf plugin add nodejs && asdf plugin add bun
asdf plugin add golang && asdf plugin add python && asdf plugin add rust
asdf install   # reads ~/.tool-versions

# 7. Symlink the configs (see table above), e.g.
ln -sf "$PWD/aerospace/.aerospace.toml" ~/.aerospace.toml
```

---

# The DX toolbelt

## Shell & navigation

### zsh + Oh My Zsh
Login shell. Framework at `~/.oh-my-zsh`, theme `robbyrussell`, plugins: `git`.

- `.zshenv` — sources `~/.cargo/env` (Rust toolchain on PATH for every shell).
- `.zprofile` — `brew shellenv` + pipx's `~/.local/bin`.
- `.zshrc` — Oh My Zsh, asdf shims, zoxide init, fzf options.

### zoxide
Smarter `cd`. Learns your most-used directories, jump with `z <fragment>`.
Wired via `eval "$(zoxide init zsh)"` in `.zshrc`.

```sh
z dotfiles      # jump to the highest-ranked match
zi              # interactive pick (uses fzf)
```

### fzf
Fuzzy finder that powers `Ctrl-T` (file picker), `Ctrl-R` (history), `Alt-C` (cd).
`.zshrc` sets `FZF_CTRL_T_OPTS`: full style, skips `.git`/`node_modules`/`target`,
previews files through `bat`, `Ctrl-/` cycles the preview pane.

### bat
`cat` with syntax highlighting, line numbers and git gutter. Also the fzf preview
renderer above.

### ripgrep (`rg`)
Fast recursive grep. Respects `.gitignore` by default.

### tmux
Terminal multiplexer — persistent sessions, splits, detach/reattach.
No custom `~/.tmux.conf` yet; running stock config.

## Editors & AI agents

### Neovim
Installed via brew. **Config lives in a separate repo** (lazy.nvim + telescope +
rose-pine, leader `,`). Not tracked here.

### Claude Code
Anthropic's terminal coding agent (cask `claude-code@latest`).
Config: `claude/settings.json` — model `opus`, `effortLevel: medium`, dark theme,
`rust-analyzer-lsp` + `clangd-lsp` plugins enabled, and a `SessionStart` hook that
turns on caveman mode (compressed responses) for every session.

### opencode
Terminal AI coding agent from the `anomalyco/tap`.
Config: `opencode/opencode.jsonc` (schema-only so far) and `opencode/package.json`
pinning `@opencode-ai/plugin`.

### VS Code
Extensions are captured in the `Brewfile` (`vscode "..."` lines) — `brew bundle`
reinstalls them all. Notables: Prettier, Tailwind, Prisma, Go, Python/Pylance,
C#, Ruby LSP, git-graph, WakaTime.

## Window management & desktop

### AeroSpace
i3-style tiling window manager for macOS (`nikitabobko/tap`).
Config: `aerospace/.aerospace.toml` → `~/.aerospace.toml`.

### Raycast
Spotlight replacement — launcher, clipboard history, snippets, extensions.
State lives in `~/.config/raycast` (machine-local, not tracked).

### touchbar-app
Custom Touch Bar widgets. Config: `touchbar-app/config.json` — clock, battery,
CPU/RAM/network graphs, and a tools group with screenshot shortcuts, a lock
hotkey, and a caffeinate toggle.

### noTunes
Blocks Apple Music from auto-launching on media keys.

### iTerm2
Terminal emulator. Preferences live in macOS defaults, not in `~/.config/iterm2`
(which only holds sockets), so nothing to track here.

## Version & package management

### Homebrew
Everything above. Taps in use: `nikitabobko/tap` (AeroSpace),
`anomalyco/tap` (opencode), `kappke/tap` (lazy-click).

### asdf
One version manager for all runtimes. Plugins installed: `nodejs`, `bun`,
`golang`, `python`, `rust`. Shims are prepended to PATH in `.zshrc`, and the
golang plugin's `set-env.zsh` is sourced for `GOROOT`/`GOPATH`.
Pinned globals (`asdf/.tool-versions`):

```
nodejs 25.8.2
bun 1.3.9
```

### uv
Fast Python package/project manager (pip + venv replacement, Rust-written).

### pipx
Installs Python CLIs into isolated venvs, binaries linked into `~/.local/bin`.

### cargo / rustup
Rust toolchain at `~/.cargo/bin` — `cargo`, `clippy`, `rustfmt`, `rust-analyzer`.

## Git

Config: `git/.gitconfig`.

```ini
[user]  name = Pedro Sehn
        email = pedroarthursehn@gmail.com
[push]  autoSetupRemote = true   # no more --set-upstream
[pull]  rebase = false
```

Global ignore (`git/ignore` → `~/.config/git/ignore`) excludes
`**/.claude/settings.local.json`.

## Databases & API clients

- **Bruno** — offline, git-friendly API client (Postman alternative).
- **Docker Desktop** — containers; `~/.docker` holds contexts/credentials.

## Media & assets

- **ffmpeg** — video/audio transcode (pulls in x264, x265, av1, opus, …).
- **imagemagick** — image conversion/manipulation.
- **pngquant** — lossy PNG compression.
- **tesseract** — OCR.
- **inkscape** / **pstoedit** / **plotutils** — vector graphics + PS/PDF → vector.
- **ghostscript** — PostScript/PDF interpreter.

## Mobile

- **scrcpy** + **android-platform-tools** — mirror and control Android over adb.

## Build toolchain

`cmake`, `ninja`, `pkgconf`, `tree-sitter`, `shaderc`, `vulkan-loader`,
`molten-vk` (Vulkan-on-Metal), `luajit` — mostly transitive deps of neovim and
the graphics/media stack, kept explicit so `brew bundle` reproduces them.

## Misc

- **lazy-click** — TUI client for ClickUp (`kappke/tap`).
- **live-server** — npm global; zero-config dev server with live reload.
- **WakaTime** — automatic coding-time tracking (`~/.wakatime`, VS Code ext).
