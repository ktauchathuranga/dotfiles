#!/bin/bash

# Source the package manager functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/package-manager.sh"

smart_install "swww"
smart_install "pywal"
smart_install "fd"
smart_install "wofi"

wal -i ~/dotfiles/wallpapers/pywallpaper.jpg
sudo cp -a ~/dotfiles/.config/hypr/wallpaper.sh ~/.config/hypr/wallpaper.sh
sudo cp -a ~/dotfiles/.config/wofi/config1 ~/.config/wofi/
sudo cp -a ~/dotfiles/.config/wofi/style1.css ~/.config/wofi/
