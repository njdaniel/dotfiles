# Dotfiles

This is my personal dotfiles repo, managed with [GNU Stow](https://www.gnu.org/software/stow/).  
It includes configs for `bash`, `zsh`, `nvim`, `tmux`, `wezterm`, and a shared `shell` environment.

## Structure

Each folder corresponds to a set of related dotfiles and is symlinked into your home directory or `.config` via Stow.

Example:

```
nvim/.config/nvim/         # Symlinks to ~/.config/nvim/
zsh/.zshrc                 # Symlinks to ~/.zshrc
shell/.config/shell/env     # Symlinks to ~/.config/shell/env
```

## Setup

1. **Clone this repository:**

   ```sh
   git clone --recursive https://github.com/njdaniel/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Run the setup script:**

   ```sh
   ./setup.sh
   ```

   On Debian/Ubuntu/Pop!_OS, this will:

   - Install base development packages: `git`, `curl`, `wget`, `ripgrep`, `fd-find`, `build-essential`, `make`, `pkg-config`, `nodejs`, `npm`, `python3`, `python3-pip`, `zsh`, `tmux`, `stow`, etc.
   - Install Go from apt if `go` is missing.
   - Install Rust with `rustup` if Rust is missing.
   - Install Docker Engine, Buildx, and Docker Compose from Docker's apt repo if Docker is missing.
   - Add the current user to the `docker` group.
   - Symlink all available configs, including the shared shell environment, into the correct places using GNU Stow.

   Optional sections can be skipped with environment variables:

   ```sh
   INSTALL_DOCKER=0 ./setup.sh
   INSTALL_RUST=0 ./setup.sh
   INSTALL_GO=0 ./setup.sh
   STOW_DOTFILES=0 ./setup.sh
   ```

   After Docker install, log out and back in, or run:

   ```sh
   newgrp docker
   ```

3. **Install any required plugin managers manually:**
   - [Oh-My-Zsh](https://ohmyz.sh/) for Zsh (if you use it)
   - [TPM](https://github.com/tmux-plugins/tpm) for Tmux
   - [lazy.nvim](https://github.com/folke/lazy.nvim) bootstraps itself on first Neovim launch — nothing to install

## Neovim

### Requirements

- **Neovim 0.11+** — the LSP setup uses `vim.lsp.config()`. Distro packages are often too old; grab the [latest stable release](https://github.com/neovim/neovim/releases/latest) instead, e.g.:

  ```sh
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  mkdir -p ~/.local/opt && tar -xzf nvim-linux-x86_64.tar.gz -C ~/.local/opt
  ln -sfn ~/.local/opt/nvim-linux-x86_64/bin/nvim ~/.local/bin/nvim
  ```

- System packages are installed by `./setup.sh` on Debian/Ubuntu/Pop!_OS. Neovim needs `git`, `ripgrep`, `fd-find`, `make`, `gcc`/`build-essential`, `nodejs`/`npm`, and `go` for the current config and tooling.

### Install

```sh
cd ~/.dotfiles && stow nvim
```

First launch bootstraps lazy.nvim, installs plugins from `lazy-lock.json`, and Mason installs LSP servers, formatters, and linters in the background (`:Mason` to watch progress).

### Health checks

- `:checkhealth` — overall status (also `:checkhealth lazy`, `:checkhealth mason`, `:checkhealth vim.lsp`)
- `:Lazy` — plugin state; `:Mason` — installed tools
- `:ConformInfo` — formatters attached to the current buffer
- `:checkhealth vim.lsp` — LSP clients attached to the current buffer (`:LspInfo` was removed from nvim-lspconfig)

### Go development

Mason installs `gopls`, `goimports`, `gofumpt`, and `golangci-lint`. Opening a `.go` file attaches gopls; saving organizes imports and formats via goimports + gofumpt; golangci-lint diagnostics appear on save (or trigger manually with `<leader>l`).

### AI assistants

Inline completions come from [copilot.vim](https://github.com/github/copilot.vim) (accept with `<C-L>`) and chat from [CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim) (`:CopilotChat`). Both authenticate through GitHub: run `:Copilot setup` once. No API keys are stored in this repo.

## Notes

- Back up your existing configs before running this setup if you have important changes.
- If you add or remove dotfile folders, update the `stow_targets` array in `setup.sh`.
- Shared shell environment exports live in `shell/.config/shell/env` and are loaded in interactive Bash/Zsh sessions (via `bash/.bashrc` and `zsh/.zshrc`).
- For submodules (like TPM), run:
  ```sh
  git submodule update --init --recursive
  ```

## Customization

Feel free to fork or modify as you like.  
If you have questions or suggestions, open an issue!
