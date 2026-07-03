#!/usr/bin/env bash
#
# dotfiles bootstrap — sets up tmux + neovim + ghostty on a fresh machine.
# Supports: macOS (Homebrew), Debian/Ubuntu (apt), Arch (pacman).
#
# Usage:
#   ./install.sh                 # interactive picker (or full setup if non-interactive)
#   ./install.sh nvim            # install only the neovim config
#   ./install.sh nvim tmux       # install multiple packages
#   ./install.sh --all           # install everything, no prompt
#   ./install.sh --list          # show available packages
#   SKIP_FONT=1 ./install.sh     # skip Nerd Font install
#
set -euo pipefail

# ----------------------------- configuration -----------------------------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TPM_REPO="https://github.com/tmux-plugins/tpm"
AVAILABLE_PACKAGES=(zsh tmux nvim ghostty)   # add more package dirs here as you grow the repo
SELECTED_PACKAGES=()

# ------------------------------- logging ---------------------------------
c_reset=$'\033[0m'; c_blue=$'\033[1;34m'; c_green=$'\033[1;32m'
c_yellow=$'\033[1;33m'; c_red=$'\033[1;31m'
info(){ printf '%s==>%s %s\n' "$c_blue" "$c_reset" "$*"; }
ok(){   printf '%s  ok%s %s\n' "$c_green" "$c_reset" "$*"; }
warn(){ printf '%s warn%s %s\n' "$c_yellow" "$c_reset" "$*"; }
err(){  printf '%s fail%s %s\n' "$c_red" "$c_reset" "$*" >&2; }
have(){ command -v "$1" >/dev/null 2>&1; }
contains(){ local x; for x in "${SELECTED_PACKAGES[@]}"; do [[ "$x" == "$1" ]] && return 0; done; return 1; }

# ------------------------------ selection ---------------------------------
usage(){
  cat <<USAGE
Usage: ./install.sh [packages...] [options]

Available packages: ${AVAILABLE_PACKAGES[*]}

Options:
  -p, --packages <list>   Comma or space separated package names
  -a, --all               Install every package, no prompt
  -l, --list              List available packages and exit
  -h, --help              Show this help

Env vars:
  SKIP_FONT=1             Skip Nerd Font install

Examples:
  ./install.sh                    # interactive picker
  ./install.sh nvim                # install only the neovim config
  ./install.sh --packages nvim,tmux
  ./install.sh --all
USAGE
}

add_packages(){
  local raw="${1//,/ }" name
  for name in $raw; do
    if [[ " ${AVAILABLE_PACKAGES[*]} " == *" $name "* ]]; then
      SELECTED_PACKAGES+=("$name")
    else
      err "Unknown package: $name (available: ${AVAILABLE_PACKAGES[*]})"
      exit 1
    fi
  done
}

parse_args(){
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) usage; exit 0 ;;
      -l|--list) printf '%s\n' "${AVAILABLE_PACKAGES[@]}"; exit 0 ;;
      -a|--all) SELECTED_PACKAGES=("${AVAILABLE_PACKAGES[@]}"); shift ;;
      -p|--packages) shift; [[ $# -gt 0 ]] || { err "--packages needs a value"; exit 1; }
                     add_packages "$1"; shift ;;
      --packages=*) add_packages "${1#*=}"; shift ;;
      -*) err "Unknown option: $1"; usage; exit 1 ;;
      *) add_packages "$1"; shift ;;
    esac
  done
}

interactive_pick(){
  echo
  info "Select packages to install:"
  local i
  for i in "${!AVAILABLE_PACKAGES[@]}"; do
    printf '  %d) %s\n' "$((i + 1))" "${AVAILABLE_PACKAGES[$i]}"
  done
  echo
  local reply tok chosen=()
  read -rp "Enter numbers or names (space/comma separated), or 'all' [all]: " reply
  reply="${reply:-all}"
  if [[ "$reply" == "all" ]]; then
    SELECTED_PACKAGES=("${AVAILABLE_PACKAGES[@]}")
    return
  fi
  reply="${reply//,/ }"
  for tok in $reply; do
    if [[ "$tok" =~ ^[0-9]+$ ]] && (( tok >= 1 && tok <= ${#AVAILABLE_PACKAGES[@]} )); then
      chosen+=("${AVAILABLE_PACKAGES[$((tok - 1))]}")
    elif [[ " ${AVAILABLE_PACKAGES[*]} " == *" $tok "* ]]; then
      chosen+=("$tok")
    else
      warn "Skipping unknown selection: $tok"
    fi
  done
  SELECTED_PACKAGES=("${chosen[@]}")
}

# ------------------------- platform detection ----------------------------
OS=""; PM=""
detect_platform(){
  if [[ "${OSTYPE:-}" == darwin* ]]; then OS=macos; PM=brew
  elif have apt-get;                  then OS=debian; PM=apt
  elif have pacman;                   then OS=arch;  PM=pacman
  else err "Unsupported platform (need macOS, apt, or pacman)"; exit 1; fi
  info "Platform: $OS  (package manager: $PM)"
}

# ------------------------------ backups ----------------------------------
backup(){
  local target="$1" bak
  bak="${target}.backup-$(date +%Y%m%d-%H%M%S)"
  warn "Backing up existing $target -> $bak"
  mv "$target" "$bak"
}

# --------------------------- core packages -------------------------------
ensure_brew(){
  if have brew; then return; fi
  info "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if   [[ -x /opt/homebrew/bin/brew ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew   ]]; then eval "$(/usr/local/bin/brew shellenv)"; fi
}

install_core(){
  local pkgs=(git stow curl)
  contains tmux && pkgs+=(tmux)
  info "Installing core tools (${pkgs[*]})..."
  case "$OS" in
    macos)  ensure_brew; brew install "${pkgs[@]}" ;;
    debian) sudo apt-get update -y
            sudo apt-get install -y "${pkgs[@]}" ca-certificates ;;
    arch)   sudo pacman -Sy --needed --noconfirm "${pkgs[@]}" ;;
  esac
  ok "Core tools installed"
}

# ------------------------------ neovim -----------------------------------
# LazyVim needs a recent Neovim. Distro packages are often too old, so on
# Debian/Ubuntu we install the official prebuilt release instead.
install_neovim(){
  if have nvim; then ok "neovim present ($(nvim --version | head -1))"; return; fi
  info "Installing neovim..."
  case "$OS" in
    macos) brew install neovim ;;
    arch)  sudo pacman -S --needed --noconfirm neovim ;;
    debian)
      local arch name url tmp
      arch="$(uname -m)"
      case "$arch" in
        x86_64|amd64)  name="nvim-linux-x86_64" ;;
        aarch64|arm64) name="nvim-linux-arm64"  ;;
        *) warn "Unknown arch $arch; using apt (may be outdated)"
           sudo apt-get install -y neovim; return ;;
      esac
      url="https://github.com/neovim/neovim/releases/latest/download/${name}.tar.gz"
      tmp="$(mktemp -d)"
      if curl -fsSL "$url" -o "$tmp/nvim.tar.gz"; then
        sudo rm -rf /opt/nvim
        sudo mkdir -p /opt/nvim
        sudo tar -xzf "$tmp/nvim.tar.gz" -C /opt/nvim --strip-components=1
        sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
        ok "neovim installed to /opt/nvim (symlinked to /usr/local/bin/nvim)"
      else
        warn "Download failed; falling back to apt (may be outdated)"
        sudo apt-get install -y neovim
      fi
      rm -rf "$tmp"
      ;;
  esac
}

# -------------------------------- tmux -----------------------------------
install_tpm(){
  local dir="$HOME/.tmux/plugins/tpm"
  if [[ -d "$dir" ]]; then ok "TPM already installed"; return; fi
  info "Installing TPM (tmux plugin manager)..."
  git clone "$TPM_REPO" "$dir"
  ok "TPM installed"
}

install_tmux_plugins(){
  local script="$HOME/.tmux/plugins/tpm/bin/install_plugins"
  if [[ -x "$script" ]]; then
    info "Installing tmux plugins via TPM..."
    "$script" >/dev/null 2>&1 && ok "tmux plugins installed" \
      || warn "Some tmux plugins may need a manual 'prefix + I' inside tmux"
  fi
}

# -------------------------------- stow -----------------------------------
# Recursively back up anything in $HOME that would block stow, at the right
# granularity: stow folds (symlinks) the shallowest directory that doesn't yet
# exist in $HOME, so we only descend where BOTH sides are real directories.
# This backs up a whole pre-existing ~/.config/nvim, while never touching the
# shared ~/.config dir itself.
backup_conflicts(){
  local src="$1" tgt="$2"
  if [[ -L "$tgt" || ! -e "$tgt" ]]; then
    return                       # existing symlink (restow handles) or nothing there (stow folds)
  elif [[ -d "$src" && -d "$tgt" ]]; then
    local child base             # both real dirs: stow can't fold here, descend
    shopt -s nullglob dotglob
    for child in "$src"/*; do
      base="$(basename "$child")"
      [[ "$base" == "." || "$base" == ".." ]] && continue
      backup_conflicts "$child" "$tgt/$base"
    done
    shopt -u nullglob dotglob
  else
    backup "$tgt"                # real file (or type mismatch) in the way
  fi
}

stow_packages(){
  have stow || { err "stow missing"; exit 1; }
  cd "$DOTFILES_DIR"
  local pkg
  for pkg in "${SELECTED_PACKAGES[@]}"; do
    [[ -d "$pkg" ]] || { warn "Package '$pkg' not found, skipping"; continue; }
    backup_conflicts "$DOTFILES_DIR/$pkg" "$HOME"
    info "Stowing $pkg -> \$HOME"
    stow --target="$HOME" --restow "$pkg"
    ok "Stowed $pkg"
  done
}

# ----------------------------- Nerd Font ---------------------------------
# Optional: LazyVim and the tmux status icons need a Nerd Font to render.
install_font(){
  [[ "${SKIP_FONT:-0}" == "1" ]] && { info "Skipping Nerd Font (SKIP_FONT=1)"; return; }
  info "Installing a Nerd Font (Meslo)..."
  case "$OS" in
    macos)
      brew install --cask font-meslo-lg-nerd-font >/dev/null 2>&1 \
        && ok "Nerd Font installed" || warn "Font install skipped/failed (non-fatal)"
      ;;
    debian|arch)
      local fd="$HOME/.local/share/fonts"
      mkdir -p "$fd"
      local base="https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M/Regular"
      if curl -fsSL "$base/MesloLGMNerdFont-Regular.ttf" \
           -o "$fd/MesloLGMNerdFont-Regular.ttf"; then
        have fc-cache && fc-cache -f "$fd" >/dev/null 2>&1 || true
        ok "Nerd Font installed to $fd"
      else
        warn "Font download failed (non-fatal) — install a Nerd Font manually"
      fi
      ;;
  esac
}

# -------------------------------- main -----------------------------------
main(){
  parse_args "$@"
  if [[ ${#SELECTED_PACKAGES[@]} -eq 0 ]]; then
    if [[ -t 0 ]]; then
      interactive_pick
    else
      info "Non-interactive shell, no packages given — installing everything"
      SELECTED_PACKAGES=("${AVAILABLE_PACKAGES[@]}")
    fi
  fi
  [[ ${#SELECTED_PACKAGES[@]} -gt 0 ]] || { err "No packages selected"; exit 1; }

  info "Starting dotfiles setup from $DOTFILES_DIR"
  info "Packages: ${SELECTED_PACKAGES[*]}"
  detect_platform
  install_core
  contains nvim && install_neovim
  contains tmux && install_tpm
  stow_packages
  contains tmux && install_tmux_plugins
  install_font
  echo
  ok "All done!"
  cat <<NEXT

Next steps:
$(contains tmux && echo '  * Start tmux (or reload:  tmux source-file ~/.tmux.conf)')
$(contains tmux && echo '  * If the status bar looks bare, press  <prefix> + I  to install plugins')
$(contains nvim && echo '  * Launch  nvim  — LazyVim will sync its plugins on first run')
  * Set your terminal font to the installed Nerd Font (Meslo) for icons
NEXT
}

main "$@"
