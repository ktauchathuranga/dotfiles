#!/bin/bash

# Source the package manager functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/package-manager.sh"

smart_install "swaync"
smart_install "gvfs"
smart_install "pywal"

wal -i ~/dotfiles/wallpapers/pywallpaper.jpg
sudo cp -a ~/dotfiles/.config/swaync ~/.config/
