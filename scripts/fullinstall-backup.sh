#!/bin/bash

# Source the package manager functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/package-manager.sh"

sudo chmod -R 777 $HOME

smart_install "reflector"
smart_install "rsync"
sudo reflector --country 'US' --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

smart_install "pywal"
smart_install "swww"
wal -i ~/dotfiles/wallpapers/walls/r82.jpg -n

smart_install "waybar"
smart_install "swaync"
smart_install "starship"
smart_install "myfetch"
smart_install "neovim"
smart_install "python-pywalfox"
smart_install "hypridle"
smart_install "hyprpicker"
smart_install "hyprshot"
smart_install "hyprlock"
smart_install "pyprland"
smart_install "wlogout"
smart_install "fd"
smart_install "cava"
smart_install "brightnessctl"
smart_install "clock-rs-git"

smart_install "nerd-fonts"

smart_install "nwg-look"
smart_install "qogir-icon-theme"
smart_install "materia-gtk-theme"
smart_install "illogical-impulse-bibata-modern-classic-bin"

smart_install "nautilus"
smart_install "gvfs"
smart_install "tumbler"
smart_install "eza"
smart_install "bottom"
smart_install "htop"

smart_install "blueman"
smart_install "bluez"
systemctl enable bluetooth

smart_install "pipewire"
smart_install "pipewire-pulse"
smart_install "pipewire-alsa"
smart_install "pipewire-jack"
smart_install "pavucontrol"
smart_install "pulsemixer"
systemctl --user enable pipewire.service pipewire-pulse.service
systemctl --user start pipewire.service pipewire-pulse.service

smart_install "gnome-network-displays"
smart_install "gst-plugins-bad"
sudo systemctl enable avahi-daemon

hyprpm add https://github.com/virtcode/hypr-dynamic-cursors
hyprpm enable dynamic-cursors

sudo cp -f -r ~/dotfiles/wallpapers ~/
sudo cp -r -f ~/dotfiles/.config/* ~/.config/
sudo cp -r -f ~/dotfiles/.bashrc ~/

notify-send "Open Terminal with MOD+Q" "Hello $USER,\nThank you for downloading dotfiles!"
