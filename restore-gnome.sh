#!/bin/bash

# Restore GNOME Settings, Bashrc, and Gitconfig Script

echo "Restoring configs..."

# --- GNOME Settings ---
if [ -f "gnome/gnome-settings.dconf" ]; then
    echo "1. Restoring GNOME settings..."
    dconf load / < gnome/gnome-settings.dconf
else
    echo "Skipping GNOME: 'gnome/gnome-settings.dconf' not found."
fi

# --- Helper Function for Dotfiles ---
restore_file() {
    local source_file=$1
    local dest_file=$2
    
    if [ -f "$source_file" ]; then
        echo "Restoring $dest_file..."
        
        # Safety: Backup the existing file on the machine before overwriting
        if [ -f "$dest_file" ]; then
            cp "$dest_file" "${dest_file}.pre-restore-backup"
            echo "   (Safety backup saved to ${dest_file}.pre-restore-backup)"
        fi

        # Overwrite file
        cp "$source_file" "$dest_file"
        echo "   $dest_file updated."
    else
        echo "Skipping $dest_file: '$source_file' backup file not found."
    fi
}

# --- Restore Dotfiles ---
echo "2. Restoring dotfiles..."

restore_file "bashrc" "$HOME/.bashrc"
restore_file "gitconfig" "$HOME/.gitconfig"

echo "------------------------------------------------"
echo "Restore complete!"
echo "Please run 'source ~/.bashrc' to apply bash changes immediately,"
echo "and log out/in to apply all GNOME changes."
