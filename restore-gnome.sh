#!/bin/bash

# Restore GNOME Settings & Bashrc Script

echo "Restoring configs..."

# --- GNOME Settings ---
if [ -f "gnome/gnome-settings.dconf" ]; then
    echo "1. Restoring GNOME settings..."
    dconf load / < gnome/gnome-settings.dconf
else
    echo "Skipping GNOME: 'gnome/gnome-settings.dconf' not found."
fi

# --- Bashrc ---
if [ -f "bashrc" ]; then
    echo "2. Restoring .bashrc..."
    
    # Safety: Backup the existing .bashrc on the machine before overwriting
    if [ -f ~/.bashrc ]; then
        cp ~/.bashrc ~/.bashrc.pre-restore-backup
        echo "   (Safety backup of existing .bashrc saved to ~/.bashrc.pre-restore-backup)"
    fi

    # Overwrite .bashrc
    cp bashrc ~/.bashrc
    echo "   ~/.bashrc updated."
else
    echo "Skipping bashrc: './bashrc' backup file not found."
fi

echo "------------------------------------------------"
echo "Restore complete!"
echo "Please run 'source ~/.bashrc' to apply bash changes immediately,"
echo "and log out/in to apply all GNOME changes."
