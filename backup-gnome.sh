#!/bin/bash

# Backup GNOME Settings & Bashrc Script

echo "Backing up configs..."

# --- GNOME Settings ---
echo "1. Exporting GNOME settings..."
# Create gnome directory if it doesn't exist
mkdir -p gnome

# Export all GNOME settings
dconf dump / > gnome/gnome-settings.dconf
echo "   GNOME settings saved to gnome/gnome-settings.dconf"

# --- Bashrc ---
echo "2. Copying .bashrc..."
cp ~/.bashrc bashrc
echo "   .bashrc saved to ./bashrc"

# --- Summary ---
echo "------------------------------------------------"
echo "Backup complete."
echo "GNOME File size: $(du -h gnome/gnome-settings.dconf | cut -f1)"
echo ""
echo "You can now commit and push to GitHub:"
echo "  git add ."
echo "  git commit -m 'Update GNOME and bashrc settings'"
echo "  git push"
