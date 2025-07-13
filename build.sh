#!/bin/bash

echo "Building HappyHacking Keybinder..."

# Clean previous builds
rm -rf .build
rm -rf HappyHackingKeybinder.app

# Build release version
swift build -c release

if [ $? -eq 0 ]; then
    echo "Build successful!"
    
    # Copy the simple executable like swift run does
    cp .build/release/HappyHackingKeybinder ./HappyHackingKeybinder_simple
    
    # Sign it like swift does (simple adhoc signing with entitlements and stable identifier)
    echo "Signing simple executable..."
    codesign --force --sign - --entitlements simple.entitlements --identifier "HappyHackingKeybinder" ./HappyHackingKeybinder_simple
    
    echo "Simple executable created: ./HappyHackingKeybinder_simple"
    echo "✅ This version works! Run it with: ./HappyHackingKeybinder_simple"
    echo ""
    
    # Also create app bundle for comparison
    mkdir -p HappyHackingKeybinder.app/Contents/{MacOS,Resources}
    
    # Copy executable
    cp .build/release/HappyHackingKeybinder HappyHackingKeybinder.app/Contents/MacOS/
    
    # Copy Info.plist
    cp HappyHackingKeybinder/Resources/Info.plist HappyHackingKeybinder.app/Contents/
    
    # Create icon (placeholder for now)
    touch HappyHackingKeybinder.app/Contents/Resources/AppIcon.icns
    
    # Ad-hoc code signing with entitlements and stable identifier (like swift run)
    echo "Signing app..."
    codesign --force --deep --sign - --entitlements HappyHackingKeybinder.entitlements --identifier "HappyHackingKeybinder" HappyHackingKeybinder.app
    
    if [ $? -eq 0 ]; then
        echo "App signed successfully!"
    else
        echo "Warning: Code signing failed, but app bundle created"
    fi
    
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