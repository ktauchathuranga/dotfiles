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
    # Check for package files in cache directory (not in subdirectories)
    if find "$CACHE_DIR" -maxdepth 1 -name "${package}-*.pkg.tar.*" 2>/dev/null | grep -q .; then
        return 0
    else
        return 1
    fi
}

# Function to check if package is in official repos
is_official_package() {
    local package="$1"
    pacman -Si "$package" >/dev/null 2>&1
}

# Function to download package to cache
download_package() {
    local package="$1"
    log "${BLUE}Downloading $package to cache...${NC}"
    
    # Try pacman first (official repos) - MUCH FASTER
    if is_official_package "$package"; then
        log "${YELLOW}Found $package in official repos, using pacman...${NC}"
        if sudo pacman -Sw --noconfirm "$package"; then
            # Copy from pacman cache to our cache
            sudo find /var/cache/pacman/pkg -name "${package}-*.pkg.tar.*" -exec cp {} "$CACHE_DIR/" \; 2>/dev/null
            # Fix permissions
            sudo chown $USER:$USER "$CACHE_DIR"/${package}-*.pkg.tar.* 2>/dev/null
            log "${GREEN}Successfully downloaded $package from official repos${NC}"
            return 0
        fi
    fi
    
    # Only use yay if not in official repos (AUR packages)
    log "${YELLOW}$package not in official repos, trying AUR with yay...${NC}"
    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || exit 1
    
    if yay -G "$package" 2>/dev/null; then
        cd "$package" || return 1
        if makepkg -s --noconfirm --skipinteg; then
            # Move built packages to cache
            find . -name "*.pkg.tar.*" -exec mv {} "$CACHE_DIR/" \;
            cd "$temp_dir"
            rm -rf "$package"
            rm -rf "$temp_dir"
            log "${GREEN}Successfully downloaded $package from AUR${NC}"
            return 0
        else
            cd "$temp_dir"
            rm -rf "$package"
        fi
    fi
    
    rm -rf "$temp_dir"
    log "${RED}Failed to download $package${NC}"
    return 1
}

# Function to install package from cache
install_from_cache() {
    local package="$1"
    local pkg_file=$(find "$CACHE_DIR" -maxdepth 1 -name "${package}-*.pkg.tar.*" 2>/dev/null | head -1)
    
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
    
    # Install from online - prioritize pacman over yay
    if is_official_package "$package"; then
        log "${BLUE}Installing $package from official repos with pacman...${NC}"
        if sudo pacman -S --noconfirm "$package"; then
            log "${GREEN}Successfully installed $package from official repos${NC}"
            return 0
        fi
    else
        log "${BLUE}Installing $package from AUR with yay...${NC}"
        if yay -S --noconfirm "$package"; then
            log "${GREEN}Successfully installed $package from AUR${NC}"
            return 0
        fi
    fi
    
    log "${RED}Failed to install $package${NC}"
    return 1
}

# Function to download all packages from scripts
download_all_packages() {
    log "${BLUE}Starting package download process...${NC}"
    
    # Clean up any leftover build directories
    find "$CACHE_DIR" -maxdepth 1 -type d -name "*" ! -name "$(basename "$CACHE_DIR")" -exec rm -rf {} \; 2>/dev/null
    
    # Categorized package lists for better organization
    local official_packages=(
        # Core system packages (official repos)
        "reflector" "rsync" "firefox" "neovim" "fd" "gvfs" "tumbler" 
        "eza" "bottom" "htop" "blueman" "bluez" "pipewire" "pipewire-pulse" 
        "pipewire-alsa" "pipewire-jack" "pavucontrol" "wofi" "git" "lazygit" "nautilus"
    )
    
    local aur_packages=(
        # AUR packages
        "python-pywal16" "swww" "waybar" "swaync" "starship" "myfetch" 
        "python-pywalfox" "hypridle" "hyprpicker" "hyprshot" "hyprlock" 
        "pyprland" "wlogout" "cava" "brightnessctl" "clock-rs-git" 
        "nerd-fonts-complete" "otf-codenewroman-nerd" "nwg-look" "qogir-icon-theme" 
        "materia-gtk-theme" "bibata-cursor-theme-bin" "pulsemixer" "gnome-network-displays" 
        "gst-plugins-bad"
    )
    
    # Process official packages first (faster)
    local total_official=${#official_packages[@]}
    local current=0
    local failed_packages=()
    
    log "${BLUE}Processing official repository packages first...${NC}"
    for package in "${official_packages[@]}"; do
        current=$((current + 1))
        log "${BLUE}[Official $current/$total_official] Processing $package...${NC}"
        
        if ! is_package_cached "$package"; then
            if ! download_package "$package"; then
                failed_packages+=("$package")
            fi
        else
            log "${GREEN}$package already cached${NC}"
        fi
    done
    
    # Process AUR packages
    local total_aur=${#aur_packages[@]}
    current=0
    
    log "${BLUE}Processing AUR packages...${NC}"
    for package in "${aur_packages[@]}"; do
        current=$((current + 1))
        log "${BLUE}[AUR $current/$total_aur] Processing $package...${NC}"
        
        if ! is_package_cached "$package"; then
            if ! download_package "$package"; then
                failed_packages+=("$package")
            fi
        else
            log "${GREEN}$package already cached${NC}"
        fi
    done
    
    if [[ ${#failed_packages[@]} -eq 0 ]]; then
        log "${GREEN}Package download process completed successfully!${NC}"
    else
        log "${YELLOW}Package download completed with some failures:${NC}"
        for pkg in "${failed_packages[@]}"; do
            log "${RED}  - $pkg${NC}"
        done
        log "${YELLOW}Failed packages can be installed online during installation.${NC}"
    fi
}

# Function to show cache status
show_cache_status() {
    log "${BLUE}Package Cache Status:${NC}"
    log "Cache directory: $CACHE_DIR"
    
    local total_packages=$(find "$CACHE_DIR" -maxdepth 1 -name "*.pkg.tar.*" 2>/dev/null | wc -l)
    local cache_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
    
    log "Total cached packages: $total_packages"
    log "Cache size: ${cache_size:-0}"
    
    if [[ $total_packages -gt 0 ]]; then
        log "\nCached packages:"
        find "$CACHE_DIR" -maxdepth 1 -name "*.pkg.tar.*" -exec basename {} \; 2>/dev/null | sort
    fi
}

# Function to clean cache
clean_cache() {
    read -p "Are you sure you want to clean the package cache? (y/N): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        # Remove package files but keep log
        find "$CACHE_DIR" -maxdepth 1 -name "*.pkg.tar.*" -delete 2>/dev/null
        # Clean up any leftover directories
        find "$CACHE_DIR" -maxdepth 1 -type d -name "*" ! -name "$(basename "$CACHE_DIR")" -exec rm -rf {} \; 2>/dev/null
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
