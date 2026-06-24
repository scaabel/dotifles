# dotfiles

Personal dev environment: **tmux** + **neovim** + **ghostty**, set up on a fresh machine with one command.

Works on macOS (Homebrew), Debian/Ubuntu (apt), and Arch (pacman).

## Quick start

```bash
git clone https://github.com/scaabel/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

That's it. The script is idempotent — safe to re-run any time.

## What the install script does

1. Detects your OS and package manager.
2. Installs core tools: `git`, `tmux`, `stow`, `curl`.
3. Installs **neovim** (latest official release on Linux, since distro packages are often too old for LazyVim).
4. Installs **TPM** (tmux plugin manager) into `~/.tmux/plugins/tpm`.
5. Symlinks the config packages into place with GNU Stow:
   `tmux/.tmux.conf` -> `~/.tmux.conf`, `nvim/.config/nvim` -> `~/.config/nvim`,
   and `ghostty/.config/ghostty` -> `~/.config/ghostty`.
6. Installs the tmux plugins listed in the config.
7. Installs a Nerd Font (Meslo) so the tmux/LazyVim icons render. Skip with `SKIP_FONT=1 ./install.sh`.

Any existing real files or directories (e.g. an old `~/.tmux.conf` or `~/.config/nvim`) are backed up to `*.backup-<timestamp>` before linking, so nothing is lost.

## Layout

```
dotfiles/
├── install.sh                  # one-shot bootstrap
├── tmux/
│   └── .tmux.conf              # stow package -> ~/.tmux.conf
├── nvim/
│   └── .config/nvim/           # stow package -> ~/.config/nvim (LazyVim)
│       ├── init.lua
│       ├── lazy-lock.json      # pinned plugin versions
│       └── lua/...
├── ghostty/
│   └── .config/ghostty/        # stow package -> ~/.config/ghostty
│       ├── config              # terminal config (Catppuccin + QOL)
│       └── themes/             # catppuccin-mocha / -latte palettes
└── README.md
```

The neovim config (a LazyVim setup) is vendored directly into this repo, so cloning `dotfiles` gives you everything. `lazy-lock.json` is committed so plugin versions are reproducible across machines.

## How it's managed (GNU Stow)

Each top-level folder is a "package". Running `stow tmux` from this directory symlinks its contents into `$HOME`, mirroring the folder structure. To add another app later:

```bash
mkdir -p git
mv ~/.gitconfig git/.gitconfig
# add "git" to STOW_PACKAGES in install.sh, then:
stow git
```

## Manual reload

```bash
# tmux
tmux source-file ~/.tmux.conf      # reload config (also: prefix + r)
# inside tmux: prefix + I           # install/update plugins
```

## Ghostty

The terminal config keeps your Catppuccin setup and adds quality-of-life tweaks for a tmux/Neovim workflow: `macos-option-as-alt` (so `<A-…>` mappings work), block cursor with no blink, `copy-on-select`, clipboard read/write allowed (seamless Neovim/tmux yank + OSC52), and `confirm-close-surface = false` since tmux persists sessions. Light/dark themes switch automatically with the OS via the `theme = dark:…,light:…` line — no helper script needed.

For true colors in tmux under Ghostty, add this to `~/.tmux.conf` (optional):

```tmux
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-ghostty:RGB"
```

> Note: the old `switch-theme.sh` was intentionally left out — it overwrote the whole config file with a palette file when run, and the native `theme = dark:…,light:…` setting replaces it.

## Notes

- Because `~/.config/nvim` is a symlink into this repo, editing your neovim config and committing it here is all one workflow — no separate repo to sync.
- Shell: zsh + oh-my-zsh (managed separately; not part of this repo yet).
