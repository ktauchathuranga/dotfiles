#!/bin/bash

# Source the package manager functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/package-manager.sh"

smart_install "waybar"
smart_install "hyprpicker"
smart_install "otf-codenewroman-nerd"
smart_install "pywal"
smart_install "blueman"
smart_install "bluez"

wal -i ~/dotfiles/wallpapers/pywallpaper.jpg
systemctl enable bluetooth
sudo cp -a ~/dotfiles/.config/waybar ~/.config/
