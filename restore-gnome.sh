#!/bin/bash

# Restore GNOME Settings Script

echo "Restoring GNOME settings..."

dconf load / < gnome/gnome-settings.dconf

echo "GNOME settings restored!  You may need to log out and back in."
