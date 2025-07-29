#!/bin/bash
yay -S hyprlock pywal
wal -i ~/Dotfiles/wallpapers/pywallpaper.jpg
sudo cp -a ~/Dotfiles/.config/wal ~/.config/
sudo cp -a ~/Dotfiles/.config/hypr/hyprlock.conf ~/.config/hypr/
