#!/bin/bash

# Backup GNOME Settings, Bashrc, and Gitconfig Script

echo "Backing up configs..."

# --- GNOME Settings ---
echo "1. Exporting GNOME settings..."
# Create gnome directory if it doesn't exist
mkdir -p gnome

# Export all GNOME settings
dconf dump / > gnome/gnome-settings.dconf
echo "   GNOME settings saved to gnome/gnome-settings.dconf"

# --- Dotfiles ---
echo "2. Copying dotfiles..."

# Backup .bashrc
cp ~/.bashrc bashrc
echo "   .bashrc saved to ./bashrc"

# Backup .gitconfig
cp ~/.gitconfig gitconfig
echo "   .gitconfig saved to ./gitconfig"

# Backup .tmux.conf
if [ -f ~/.tmux.conf ]; then
	cp ~/.tmux.conf tmux.conf
	echo "   .tmux.conf saved to ./tmux.conf"
else
	echo "   .tmux.conf not found, skipping."
fi

# --- Summary ---
echo "------------------------------------------------"
echo "Backup complete."
echo "GNOME File size: $(du -h gnome/gnome-settings.dconf | cut -f1)"
echo ""
echo "You can now commit and push to GitHub:"
echo "  git add ."
echo "  git commit -m 'Update GNOME, bashrc, and gitconfig'"
echo "  git push"
