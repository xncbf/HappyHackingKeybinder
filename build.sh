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
    
    # Sign it like swift does (simple adhoc signing with stable identifier)
    echo "Signing simple executable..."
    codesign --force --sign - --identifier "com.happyhacking.keybinder" ./HappyHackingKeybinder_simple
    
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
    
    # Try to find a developer certificate first
    DEVELOPER_ID=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | awk '{print $2}')
    
    if [ -z "$DEVELOPER_ID" ]; then
        # Try Apple Development certificate
        DEVELOPER_ID=$(security find-identity -v -p codesigning | grep "Apple Development" | head -1 | awk '{print $2}')
    fi
    
    if [ -z "$DEVELOPER_ID" ]; then
        # Fall back to ad-hoc signing
        echo "No developer certificate found, using ad-hoc signing..."
        echo "Note: This may cause permission issues! Consider getting a developer certificate."
        codesign --force --deep --sign - --identifier "com.happyhacking.keybinder" --entitlements HappyHackingKeybinder.entitlements HappyHackingKeybinder.app
    else
        echo "Signing app with developer certificate: $DEVELOPER_ID"
        codesign --force --deep --sign "$DEVELOPER_ID" --identifier "com.happyhacking.keybinder" --entitlements HappyHackingKeybinder.entitlements HappyHackingKeybinder.app
    fi
    
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