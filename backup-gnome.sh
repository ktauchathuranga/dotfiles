#!/bin/bash

# Backup GNOME Settings Script

echo "Backing up GNOME settings..."

# Create gnome directory if it doesn't exist
mkdir -p gnome

# Export all GNOME settings
dconf dump / > gnome/gnome-settings.dconf

echo "GNOME settings backed up to gnome/gnome-settings.dconf"
echo "File size: $(du -h gnome/gnome-settings.dconf | cut -f1)"
echo ""
echo "You can now commit and push to GitHub:"
echo "  git add ."
echo "  git commit -m 'Update GNOME settings'"
echo "  git push"
