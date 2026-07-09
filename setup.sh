#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APT_UPDATED=0

# Toggle optional sections with env vars, e.g. INSTALL_DOCKER=0 ./setup.sh
INSTALL_BASE_PACKAGES="${INSTALL_BASE_PACKAGES:-1}"
INSTALL_GO="${INSTALL_GO:-1}"
INSTALL_RUST="${INSTALL_RUST:-1}"
INSTALL_DOCKER="${INSTALL_DOCKER:-1}"
STOW_DOTFILES="${STOW_DOTFILES:-1}"

on_debian_like() {
  [[ -f /etc/debian_version ]]
}

apt_update_once() {
  if [[ "$APT_UPDATED" -eq 0 ]]; then
    sudo apt update
    APT_UPDATED=1
  fi
}

install_apt_packages() {
  if [[ "$INSTALL_BASE_PACKAGES" != "1" ]]; then
    echo "Skipping base package install."
    return
  fi

  if ! on_debian_like; then
    echo "Skipping apt package install: this script currently supports Debian/Ubuntu/Pop!_OS only."
    return
  fi

  echo "Installing base development packages..."
  apt_update_once
  sudo apt install -y \
    build-essential \
    ca-certificates \
    curl \
    fd-find \
    git \
    gnupg \
    lsb-release \
    make \
    nodejs \
    npm \
    pkg-config \
    python3 \
    python3-pip \
    ripgrep \
    stow \
    tmux \
    unzip \
    wget \
    zsh

  # Ubuntu/Debian package the fd binary as fdfind.
  mkdir -p "$HOME/.local/bin"
  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
}

install_go() {
  if [[ "$INSTALL_GO" != "1" ]]; then
    echo "Skipping Go install."
    return
  fi

  if command -v go >/dev/null 2>&1; then
    echo "Go already installed: $(go version)"
    return
  fi

  if ! on_debian_like; then
    echo "Go not found. Please install Go manually for your OS."
    return
  fi

  echo "Installing Go from apt..."
  apt_update_once
  sudo apt install -y golang-go
}

install_rust() {
  if [[ "$INSTALL_RUST" != "1" ]]; then
    echo "Skipping Rust install."
    return
  fi

  if command -v rustup >/dev/null 2>&1; then
    echo "Rust already installed. Updating toolchain..."
    rustup update || true
    return
  fi

  if command -v cargo >/dev/null 2>&1; then
    echo "Cargo already installed, but rustup was not found. Leaving existing Rust install alone."
    return
  fi

  echo "Installing Rust with rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

  # Make cargo available for the rest of this script when possible.
  if [[ -f "$HOME/.cargo/env" ]]; then
    # shellcheck disable=SC1091
    source "$HOME/.cargo/env"
  fi
}

install_docker() {
  if [[ "$INSTALL_DOCKER" != "1" ]]; then
    echo "Skipping Docker install."
    return
  fi

  if command -v docker >/dev/null 2>&1; then
    echo "Docker already installed: $(docker --version)"
    return
  fi

  if ! on_debian_like; then
    echo "Docker not found. Please install Docker manually for your OS."
    return
  fi

  # shellcheck disable=SC1091
  source /etc/os-release

  local docker_os=""
  local codename="${VERSION_CODENAME:-}"

  case "${ID:-}" in
    ubuntu)
      docker_os="ubuntu"
      ;;
    pop)
      docker_os="ubuntu"
      codename="${UBUNTU_CODENAME:-$codename}"
      ;;
    debian)
      docker_os="debian"
      ;;
    *)
      echo "Skipping Docker install: unsupported distro ID '${ID:-unknown}'."
      return
      ;;
  esac

  if [[ -z "$codename" ]]; then
    echo "Skipping Docker install: could not determine distro codename."
    return
  fi

  echo "Installing Docker from the official apt repository..."
  sudo install -m 0755 -d /etc/apt/keyrings

  local keyring="/etc/apt/keyrings/docker.gpg"
  if [[ ! -f "$keyring" ]]; then
    curl -fsSL "https://download.docker.com/linux/${docker_os}/gpg" | sudo gpg --dearmor -o "$keyring"
    sudo chmod a+r "$keyring"
  fi

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=${keyring}] https://download.docker.com/linux/${docker_os} ${codename} stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt update
  APT_UPDATED=1

  sudo apt install -y \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin

  if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl enable --now docker || true
  fi

  if [[ -n "${USER:-}" ]]; then
    sudo usermod -aG docker "$USER" || true
    echo "Added $USER to the docker group. Log out and back in, or run 'newgrp docker', before using Docker without sudo."
  fi
}

stow_dotfiles() {
  if [[ "$STOW_DOTFILES" != "1" ]]; then
    echo "Skipping dotfile stow."
    return
  fi

  if ! command -v stow >/dev/null 2>&1; then
    echo "GNU Stow is required but was not found. Install it and rerun this script."
    exit 1
  fi

  echo "Setting up dotfiles using GNU Stow..."

  local stow_targets=(
    shell
    wezterm
    bash
    zsh
    nvim
    tmux
  )

  cd "$DOTFILES_DIR"

  for target in "${stow_targets[@]}"; do
    if [[ -d "$target" ]]; then
      echo "Stowing $target"
      stow -R "$target"
    else
      echo "Skipping $target, directory not found."
    fi
  done
}

install_apt_packages
install_go
install_rust
install_docker
stow_dotfiles

echo ""
echo "All done!"
echo ""
echo "Next steps:"
echo "- Restart your shell so PATH and group changes take effect."
echo "- For Docker without sudo, log out and back in or run: newgrp docker"
echo "- Open Neovim and run: :Lazy sync, :TSUpdate, :checkhealth"
echo "- If you use TPM, install tmux plugins with prefix + I."
