#!/bin/bash

# Source the package manager functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/package-manager.sh"

# Ask if they want automatic or manual installation
read -p "Do you want automatic (default) or manual installation? (a/m): " install_choice
install_choice=${install_choice:-a}  # Default to 'a' if empty

# Ask if they want to backup their .config
read -p "Do you want to backup your current .config directory? (y/n, default: y): " backup_choice
backup_choice=${backup_choice:-y}  # Default to 'y' if empty

if [[ "$backup_choice" == "y" ]]; then
    cp -r ~/.config ~/.config_backup
    echo "Backup of .config created at ~/.config_backup"
fi

# Ask if they want to download packages to cache first
read -p "Do you want to download all packages to cache first? (y/n, default: y): " cache_choice
cache_choice=${cache_choice:-y}

if [[ "$cache_choice" == "y" ]]; then
    echo "Downloading packages to cache..."
    download_all_packages
fi

# Automatic install section
if [[ $install_choice == "a" ]]; then
    sudo chmod -R 777 $HOME
    
    # Install packages using smart_install function
    packages=(
        "reflector" "rsync" "python-pywal16" "swww" "firefox" "neovim" "waybar" 
        "swaync" "starship" "myfetch" "python-pywalfox" "hypridle" "hyprpicker" 
        "hyprshot" "hyprlock" "pyprland" "wlogout" "fd" "cava" "brightnessctl" 
        "clock-rs-git" "nerd-fonts" "nwg-look" "qogir-icon-theme" "materia-gtk-theme" 
        "illogical-impulse-bibata-modern-classic-bin" "nautilus" "gvfs" "tumbler" 
        "eza" "bottom" "htop" "blueman" "bluez" "pipewire" "pipewire-pulse" 
        "pipewire-alsa" "pipewire-jack" "pavucontrol" "pulsemixer" "gnome-network-displays" 
        "gst-plugins-bad" "polkit-gnome"
    )
    
    for package in "${packages[@]}"; do
        smart_install "$package"
    done
    
    sudo reflector --country 'IN' --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
    systemctl enable bluetooth
    systemctl --user enable pipewire.service
    systemctl --user enable pipewire-pulse.service
    systemctl --user start pipewire.service
    systemctl --user start pipewire-pulse.service
    sudo systemctl enable avahi-daemon
    
    # Set wallpaper
    wal -i ~/dotfiles/wallpapers/pywallpaper.jpg -n
    
    # Dynamic-Cursors setup
    hyprpm add https://github.com/virtcode/hypr-dynamic-cursors
    hyprpm enable dynamic-cursors
    
    # Copy files
    sudo cp -a ~/dotfiles/wallpapers ~/
    sudo cp -a ~/dotfiles/.config/* ~/.config/
    sudo cp -a ~/dotfiles/.bashrc ~/
    
    notify-send "Open Terminal with MOD+Q" "Hello $USER,\nThank you for downloading my dotfiles\n-EF"

# Manual install section
elif [[ $install_choice == "m" ]]; then
    sudo chmod -R 777 $HOME
    
    read -p "Do you want to change your mirrorlist to the best one for US? (y/n, default: y): " mirror_choice
    mirror_choice=${mirror_choice:-y}
    
    if [[ "$mirror_choice" == "y" ]]; then
        smart_install "reflector"
        smart_install "rsync"
        sudo reflector --country 'US' --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
    fi
    
    # Confirm each package installation
    for package in python-pywal16 swww polkit-gnome waybar swaync starship myfetch firefox neovim python-pywalfox hypridle hyprpicker hyprshot hyprlock pyprland wlogout fd cava brightnessctl clock-rs-git nerd-fonts nwg-look qogir-icon-theme materia-gtk-theme illogical-impulse-bibata-modern-classic-bin nautilus gvfs tumbler eza bottom htop; do
        read -p "Do you want to install $package? (y/n, default: y): " choice
        choice=${choice:-y}
        if [[ "$choice" == "y" ]]; then
            smart_install "$package"
            clear
        fi
    done
    
    wal -i ~/dotfiles/wallpapers/pywallpaper.jpg -n
    
    # Ask for bluetooth
    read -p "Do you want to install Bluetooth support? (y/n, default: y): " bluetooth_choice
    bluetooth_choice=${bluetooth_choice:-y}
    if [[ "$bluetooth_choice" == "y" ]]; then
        smart_install "blueman"
        smart_install "bluez"
        systemctl enable bluetooth
    fi
    
    # Ask for Pipewire and Network Displays
    read -p "Do you want to configure Pipewire and Network Displays? (y/n, default: y): " pipewire_choice
    pipewire_choice=${pipewire_choice:-y}
    if [[ "$pipewire_choice" == "y" ]]; then
        for pkg in pipewire pipewire-pulse pipewire-alsa pipewire-jack pavucontrol pulsemixer gnome-network-displays gst-plugins-bad; do
            smart_install "$pkg"
        done
        systemctl --user enable pipewire.service
        systemctl --user enable pipewire-pulse.service
        systemctl --user start pipewire.service
        systemctl --user start pipewire-pulse.service
    fi
    
    # Dynamic-Cursors setup
    read -p "Do you want to enable Dynamic-Cursors? (y/n, default: y): " cursors_choice
    cursors_choice=${cursors_choice:-y}
    if [[ "$cursors_choice" == "y" ]]; then
        hyprpm add https://github.com/virtcode/hypr-dynamic-cursors
        hyprpm enable dynamic-cursors
    fi
    
    # Copy files
    sudo cp -a ~/dotfiles/wallpapers ~/
    sudo cp -a ~/dotfiles/.config/* ~/.config/
    sudo cp -a ~/dotfiles/.bashrc ~/
    
    notify-send "Open Terminal with MOD+Q" "Hello $USER,\nThank you for downloading my dotfiles\n-EF"
fi
