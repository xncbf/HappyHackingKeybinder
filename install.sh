#!/bin/bash

echo "Installing HappyHacking Keybinder..."

# Build the app
./build.sh

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "Choose installation method:"
    echo "1. App Bundle (recommended for normal use)"
    echo "2. Simple Executable (for development/testing)"
    read -p "Enter your choice (1 or 2): " choice
    
    case $choice in
        1)
            echo "Installing app bundle to /Applications..."
            cp -r HappyHackingKeybinder.app /Applications/
            echo "✅ Installed to /Applications/HappyHackingKeybinder.app"
            echo ""
            echo "🔐 IMPORTANT: You need to grant Accessibility permission"
            echo "1. Go to System Preferences > Security & Privacy > Privacy > Accessibility"
            echo "2. Click the lock and enter your password"
            echo "3. Add HappyHackingKeybinder and check the box"
            echo ""
            echo "Starting the app..."
            open /Applications/HappyHackingKeybinder.app
            ;;
        2)
            echo "Using simple executable..."
            echo "You can run it with: ./HappyHackingKeybinder_simple"
            echo "Note: This version works but doesn't have a menu bar icon"
            ;;
        *)
            echo "Invalid choice. Exiting."
            ;;
    esac
else
    echo "❌ Build failed!"
    exit 1
fi