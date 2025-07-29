#!/bin/bash

# Source the package manager functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/package-manager.sh"

smart_install "neovim"
smart_install "pywal"
smart_install "lazygit"

wal -i ~/dotfiles/wallpapers/pywallpaper.jpg
sudo cp -a ~/dotfiles/.config/nvim ~/.config/
