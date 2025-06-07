#!/usr/bin/env bash

set -e

# Function to check for stow and install if needed (Debian/Ubuntu only)
install_stow() {
  if ! command -v stow &> /dev/null; then
    echo "GNU Stow not found. Installing..."
    if [ -f /etc/debian_version ]; then
      sudo apt update && sudo apt install -y stow
    else
      echo "Please install GNU Stow manually for your OS."
      exit 1
    fi
  fi
}

echo "Setting up dotfiles using GNU Stow..."

install_stow

# List your managed directories here
stow_targets=(
  wezterm
  bash
  zsh
  nvim
  tmux
  git
)

cd "$(dirname "$0")"

for target in "${stow_targets[@]}"; do
  if [ -d "$target" ]; then
    echo "Stowing $target"
    stow "$target"
  else
    echo "Skipping $target, directory not found."
  fi
done

echo "All done!"

echo ""
echo "If you use Oh-My-Zsh, TPM (tmux plugin manager), or other plugin managers, please install them separately if not already installed."
