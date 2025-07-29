#!/bin/bash

# Configuration
CACHE_DIR="$HOME/dotfiles/package_cache"
LOG_FILE="$HOME/dotfiles/package_cache/package_manager.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"
touch "$LOG_FILE"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo -e "$1"
}

# Function to check if package is available in cache
is_package_cached() {
    local package="$1"
    if find "$CACHE_DIR" -name "${package}-*.pkg.tar.*" | grep -q .; then
        return 0
    else
        return 1
    fi
}

# Function to download package to cache
download_package() {
    local package="$1"
    log "${BLUE}Downloading $package to cache...${NC}"
    
    cd "$CACHE_DIR" || exit 1
    
    # Try yay first (for AUR packages)
    if yay -G "$package" 2>/dev/null; then
        cd "$package" || return 1
        if makepkg -s --noconfirm; then
            mv *.pkg.tar.* "../"
            cd ..
            rm -rf "$package"
            log "${GREEN}Successfully downloaded $package to cache${NC}"
            return 0
        else
            cd ..
            rm -rf "$package"
        fi
    fi
    
    # Try pacman (for official packages)
    if pacman -Sp "$package" >/dev/null 2>&1; then
        if sudo pacman -Sw --noconfirm "$package"; then
            # Copy from pacman cache to our cache
            sudo cp /var/cache/pacman/pkg/${package}-*.pkg.tar.* "$CACHE_DIR/" 2>/dev/null || true
            log "${GREEN}Successfully downloaded $package to cache${NC}"
            return 0
        fi
    fi
    
    log "${RED}Failed to download $package${NC}"
    return 1
}

# Function to install package from cache
install_from_cache() {
    local package="$1"
    local pkg_file=$(find "$CACHE_DIR" -name "${package}-*.pkg.tar.*" | head -1)
    
    if [[ -n "$pkg_file" ]]; then
        log "${YELLOW}Installing $package from cache: $(basename "$pkg_file")${NC}"
        if sudo pacman -U --noconfirm "$pkg_file"; then
            log "${GREEN}Successfully installed $package from cache${NC}"
            return 0
        else
            log "${RED}Failed to install $package from cache${NC}"
            return 1
        fi
    else
        return 1
    fi
}

# Function to install package (cache first, then online)
smart_install() {
    local package="$1"
    
    # Check if already installed
    if pacman -Qi "$package" >/dev/null 2>&1; then
        log "${GREEN}$package is already installed${NC}"
        return 0
    fi
    
    # Try to install from cache first
    if is_package_cached "$package"; then
        if install_from_cache "$package"; then
            return 0
        else
            log "${YELLOW}Cache installation failed, trying online...${NC}"
        fi
    fi
    
    # Install from online
    log "${BLUE}Installing $package from online sources...${NC}"
    if yay -S --noconfirm "$package"; then
        log "${GREEN}Successfully installed $package from online${NC}"
        # Download to cache for future use
        download_package "$package" &
        return 0
    else
        log "${RED}Failed to install $package${NC}"
        return 1
    fi
}

# Function to download all packages from scripts
download_all_packages() {
    log "${BLUE}Starting package download process...${NC}"
    
    # List of all packages from your scripts
    local packages=(
        # Core system packages
        "reflector" "rsync" "python-pywal16" "pywal" "swww" "firefox" "neovim"
        
        # Hyprland ecosystem
        "waybar" "swaync" "starship" "myfetch" "python-pywalfox" "hypridle" 
        "hyprpicker" "hyprshot" "hyprlock" "pyprland" "wlogout" "fd" "cava" 
        "brightnessctl" "clock-rs-git"
        
        # Fonts and themes
        "nerd-fonts" "otf-codenewroman-nerd" "nwg-look" "qogir-icon-theme" 
        "materia-gtk-theme" "illogical-impulse-bibata-modern-classic-bin"
        
        # File management
        "nautilus" "thunar" "gvfs" "tumbler" "eza" "bottom" "htop" "polkit-gnome"
        
        # Applications
        #"libreoffice-fresh" "spotify" "ncspot" "discord" "code"
        
        # Audio/Bluetooth
        "blueman" "bluez" "pipewire" "pipewire-pulse" "pipewire-alsa" 
        "pipewire-jack" "pavucontrol" "pulsemixer"
        
        # Network and media
        "gnome-network-displays" "gst-plugins-bad"
        
        # Additional tools
        "wofi" "lazygit"
    )
    
    local total=${#packages[@]}
    local current=0
    
    for package in "${packages[@]}"; do
        current=$((current + 1))
        log "${BLUE}[$current/$total] Processing $package...${NC}"
        
        if ! is_package_cached "$package"; then
            download_package "$package"
        else
            log "${GREEN}$package already cached${NC}"
        fi
    done
    
    log "${GREEN}Package download process completed!${NC}"
}

# Function to show cache status
show_cache_status() {
    log "${BLUE}Package Cache Status:${NC}"
    log "Cache directory: $CACHE_DIR"
    
    local total_packages=$(find "$CACHE_DIR" -name "*.pkg.tar.*" | wc -l)
    local cache_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
    
    log "Total cached packages: $total_packages"
    log "Cache size: ${cache_size:-0}"
    
    if [[ $total_packages -gt 0 ]]; then
        log "\nCached packages:"
        find "$CACHE_DIR" -name "*.pkg.tar.*" -exec basename {} \; | sort
    fi
}

# Function to clean cache
clean_cache() {
    read -p "Are you sure you want to clean the package cache? (y/N): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        rm -rf "$CACHE_DIR"/*.pkg.tar.*
        log "${GREEN}Cache cleaned successfully${NC}"
    else
        log "${YELLOW}Cache cleaning cancelled${NC}"
    fi
}

# Main menu
case "$1" in
    "download")
        download_all_packages
        ;;
    "install")
        if [[ -n "$2" ]]; then
            smart_install "$2"
        else
            log "${RED}Usage: $0 install <package_name>${NC}"
        fi
        ;;
    "status")
        show_cache_status
        ;;
    "clean")
        clean_cache
        ;;
    *)
        echo -e "${BLUE}Hyprland Rise Package Manager${NC}"
        echo "Usage: $0 {download|install|status|clean}"
        echo ""
        echo "Commands:"
        echo "  download    - Download all packages needed for Hyprland Rise"
        echo "  install     - Install a specific package (cache first, then online)"
        echo "  status      - Show cache status and list cached packages"
        echo "  clean       - Clean the package cache"
        echo ""
        echo "Examples:"
        echo "  $0 download                    # Download all packages"
        echo "  $0 install waybar             # Install waybar (cache first)"
        echo "  $0 status                     # Show cache status"
        echo "  $0 clean                      # Clean cache"
        ;;
esac
