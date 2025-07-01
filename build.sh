#!/bin/bash

echo "Building HappyHacking Keybinder..."

# Clean previous builds
rm -rf .build
rm -rf HappyHackingKeybinder.app

# Build release version
swift build -c release

if [ $? -eq 0 ]; then
    echo "Build successful!"
    
    # Create app bundle structure
    mkdir -p HappyHackingKeybinder.app/Contents/{MacOS,Resources}
    
    # Copy executable
    cp .build/release/HappyHackingKeybinder HappyHackingKeybinder.app/Contents/MacOS/
    
    # Copy Info.plist
    cp HappyHackingKeybinder/Resources/Info.plist HappyHackingKeybinder.app/Contents/
    
    # Create icon (placeholder for now)
    touch HappyHackingKeybinder.app/Contents/Resources/AppIcon.icns
    
    echo "App bundle created: HappyHackingKeybinder.app"
    echo ""
    echo "To install:"
    echo "1. Move HappyHackingKeybinder.app to /Applications"
    echo "2. Open the app and grant accessibility permission"
    echo "3. (Optional) Add to Login Items for auto-start"
else
    echo "Build failed!"
    exit 1
fi