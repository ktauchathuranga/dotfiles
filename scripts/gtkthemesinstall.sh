#!/bin/bash

# Source the package manager functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/package-manager.sh"

smart_install "nwg-look"
smart_install "qogir-icon-theme"
smart_install "materia-gtk-theme"
smart_install "illogical-impulse-bibata-modern-classic-bin"

echo "___________________________________________"
echo "Use nwg-look to set gtk themes for hyprland"
echo "___________________________________________"
