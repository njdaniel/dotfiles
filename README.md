# Dotfiles

This is my personal dotfiles repo, managed with [GNU Stow](https://www.gnu.org/software/stow/).  
It includes configs for `bash`, `zsh`, `nvim`, `tmux`, `git`, `starship`, `alacritty`, and more.

## Structure

Each folder corresponds to a set of related dotfiles and is symlinked into your home directory or `.config` via Stow.

Example:

```
nvim/.config/nvim/         # Symlinks to ~/.config/nvim/
zsh/.zshrc                 # Symlinks to ~/.zshrc
```

## Setup

1. **Clone this repository:**

   ```sh
   git clone --recursive https://github.com/YOURUSERNAME/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Run the setup script:**

   ```sh
   ./setup.sh
   ```

   This will:

   - Check for GNU Stow (and try to install it on Debian/Ubuntu)
   - Symlink all available configs into the correct places

3. **Install any required plugin managers manually:**
   - [Oh-My-Zsh](https://ohmyz.sh/) for Zsh (if you use it)
   - [TPM](https://github.com/tmux-plugins/tpm) for Tmux
   - [Lazy.nvim](https://github.com/folke/lazy.nvim) or your Neovim plugin manager

## Notes

- Back up your existing configs before running this setup if you have important changes.
- If you add or remove dotfile folders, update the `stow_targets` array in `setup.sh`.
- For submodules (like TPM), run:
  ```sh
  git submodule update --init --recursive
  ```

## Customization

Feel free to fork or modify as you like.  
If you have questions or suggestions, open an issue!
