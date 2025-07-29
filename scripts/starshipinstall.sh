#!/bin/bash

# Source the package manager functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/package-manager.sh"

smart_install "starship"
sudo cp -a ~/dotfiles/.config/starship.toml ~/.config/
