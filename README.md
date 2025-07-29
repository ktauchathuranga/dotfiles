# 🌟 Hyprland Dotfiles

A beautiful and functional Arch Linux Hyprland configuration with intelligent package caching and automated installation scripts.

![Hyprland Desktop](https://img.shields.io/badge/WM-Hyprland-blue?style=for-the-badge&logo=wayland)
![Arch Linux](https://img.shields.io/badge/OS-Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux)
![Waybar](https://img.shields.io/badge/Bar-Waybar-purple?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## ✨ Features

- 🎨 **Dynamic Theming** with pywal - Automatically generates color schemes from wallpapers
- 🖥️ **Hyprland Window Manager** - Modern Wayland compositor with smooth animations
- 📊 **Waybar Status Bar** - Customizable and feature-rich status bar
- 🔔 **SwayNC Notifications** - Beautiful notification center
- 🚀 **Smart Package Caching** - Offline installation capability with local package cache
- 🎭 **Multiple Installation Options** - Automatic, manual, and component-specific installations
- 🌈 **Custom Styling** - Cohesive design across all components
- 📁 **Organized Structure** - Modular installation scripts for easy maintenance

## 🖼️ Screenshots
[Screenshots] (docs/1.png)

## 📦 What's Included

### Core Components
- **Window Manager**: Hyprland with dynamic cursors plugin
- **Status Bar**: Waybar with custom styling and media player integration
- **Notifications**: SwayNC with custom themes
- **Terminal Enhancement**: Starship prompt
- **Wallpaper Management**: swww + pywal for dynamic theming
- **Application Launcher**: Wofi with custom styling
- **Lock Screen**: Hyprlock
- **Logout Menu**: Wlogout

### Applications & Tools
- **File Managers**: Nautilus, Thunar
- **Editors**: Neovim with custom config
- **Audio**: Pipewire stack with pavucontrol
- **Bluetooth**: Blueman
- **System Monitoring**: htop, bottom, cava
- **Media**: Spotify, ncspot
- **Development**: VSCode, Git tools

### Themes & Fonts
- **GTK Theme**: Materia
- **Icon Theme**: Qogir
- **Cursor Theme**: Bibata Modern Classic
- **Fonts**: Nerd Fonts collection

## 🚀 Quick Installation

### Prerequisites
```bash
# Install yay (AUR helper) if not already installed
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### One-Command Installation
```bash
git clone https://github.com/MadhukaH/dotfiles.git ~/dotfiles
cd ~/dotfiles/scripts
chmod +x *.sh
./fullinstall.sh
```

## 📋 Installation Options

### 1. Full Automatic Installation
Installs everything with default settings:
```bash
./fullinstall.sh
# Choose 'a' for automatic installation
```

### 2. Manual Installation
Choose which components to install:
```bash
./fullinstall.sh
# Choose 'm' for manual installation
```

### 3. Component-Specific Installation
Install individual components:
```bash
./waybarinstall.sh      # Install Waybar
./nviminstall.sh        # Install Neovim config
./swayncinstall.sh      # Install notification center
./wallpapersolution.sh  # Install wallpaper management
./gtkthemesinstall.sh   # Install GTK themes
```

### 4. Backup Installation
Use the backup installation script:
```bash
./fullinstall-backup.sh
```

## 🎯 Smart Package Management

This dotfiles setup includes an intelligent package caching system for faster and offline installations.

### Download All Packages to Cache
```bash
./package-manager.sh download
```

### Check Cache Status
```bash
./package-manager.sh status
```

### Install Specific Package (Cache First)
```bash
./package-manager.sh install <package-name>
```

### Clean Package Cache
```bash
./package-manager.sh clean
```

### How It Works
1. **Smart Installation**: Always checks local cache first, falls back to online
2. **Automatic Caching**: Downloads packages to cache after online installation
3. **Offline Support**: Can install entirely from cache when all packages are available
4. **Error Handling**: Graceful fallbacks when cache installation fails

## 🔧 Configuration

### Key Bindings
| Key Combination | Action |
|----------------|--------|
| `SUPER + Q` | Open Terminal |
| `SUPER + C` | Close Window |
| `SUPER + M` | Exit Hyprland |
| `SUPER + E` | File Manager |
| `SUPER + V` | Toggle Floating |
| `SUPER + R` | Application Launcher |
| `SUPER + J` | Toggle Split |

*Modify `~/.config/hypr/hyprland.conf` for custom keybindings*

### Waybar Configuration
- **Config**: `~/.config/waybar/config.jsonc`
- **Styling**: `~/.config/waybar/style.css`
- **Features**: Workspaces, system stats, media player, battery, network

### Wallpaper Management
```bash
# Set a new wallpaper and generate color scheme
wal -i /path/to/your/wallpaper.jpg
```

## 📁 Project Structure

```
dotfiles/
├── .config/                    # Configuration files
│   ├── hypr/                  # Hyprland configuration
│   ├── waybar/                # Waybar configuration
│   ├── swaync/                # Notification configuration
│   ├── nvim/                  # Neovim configuration
│   ├── wofi/                  # Application launcher
│   └── ...
├── scripts/                   # Installation scripts
│   ├── package-manager.sh     # Smart package management
│   ├── fullinstall.sh         # Main installation script
│   ├── fullinstall-backup.sh  # Backup installation
│   ├── waybarinstall.sh       # Waybar installation
│   ├── nviminstall.sh         # Neovim installation
│   └── ...
├── wallpapers/               # Wallpaper collection
├── package_cache/            # Local package cache (created automatically)
└── .bashrc                   # Bash configuration
```

## 🛠️ Customization

### Adding New Wallpapers
1. Add wallpapers to `~/dotfiles/wallpapers/`
2. Use `wal -i /path/to/wallpaper` to apply and generate color scheme

### Modifying Waybar
1. Edit `~/.config/waybar/config.jsonc` for layout changes
2. Edit `~/.config/waybar/style.css` for styling changes
3. Restart waybar: `killall waybar && waybar &`

### Changing Themes
```bash
# Use nwg-look for GTK theme changes
nwg-look
```

## 🔍 Troubleshooting

### Common Issues

**Package Installation Fails**
```bash
# Clean package cache and try again
./package-manager.sh clean
./package-manager.sh download
```

**Waybar Not Starting**
```bash
# Check waybar configuration
waybar --config ~/.config/waybar/config.jsonc --style ~/.config/waybar/style.css
```

**Hyprland Not Starting**
```bash
# Check Hyprland logs
journalctl -u display-manager -f
```

**Audio Issues**
```bash
# Restart PipeWire services
systemctl --user restart pipewire pipewire-pulse
```

## 📚 Dependencies

### Core Dependencies
- `hyprland` - Window manager
- `waybar` - Status bar
- `swaync` - Notification daemon
- `pywal` - Color scheme generator
- `swww` - Wallpaper daemon

### Optional Dependencies
- `spotify` - Music streaming
- `discord` - Communication
- `code` - Text editor
- `libreoffice-fresh` - Office suite

*Full package list available in `package-manager.sh`*

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Original dotfiles inspiration from [@elifouts](https://github.com/elifouts/Dotfiles)
- [Hyprland](https://hyprland.org/) - Amazing Wayland compositor
- [Waybar](https://github.com/Alexays/Waybar) - Highly customizable status bar
- [pywal](https://github.com/dylanaraps/pywal) - Color scheme generator
- The Arch Linux and Hyprland communities

## 📧 Contact

- GitHub: [@ktauchathuranga](https://github.com/ktauchathuranga)
- Issues: [Create an issue](https://github.com/ktauchathuranga/dotfiles/issues)

---
