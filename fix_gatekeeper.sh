#!/bin/bash

# Fix macOS Gatekeeper warnings for HappyHackingKeybinder
# Run this script if you're getting security warnings

echo "🔧 HappyHackingKeybinder Gatekeeper Fix"
echo "======================================="
echo ""

APP_PATH="/Applications/HappyHackingKeybinder.app"
LOCAL_APP_PATH="./HappyHackingKeybinder.app"

# Check if app exists in Applications folder
if [ -d "$APP_PATH" ]; then
    echo "✅ Found app in Applications folder"
    TARGET_PATH="$APP_PATH"
elif [ -d "$LOCAL_APP_PATH" ]; then
    echo "✅ Found app in current directory"
    TARGET_PATH="$LOCAL_APP_PATH"
else
    echo "❌ HappyHackingKeybinder.app not found"
    echo "Please build the app first with: ./build.sh"
    exit 1
fi

echo "🔍 Checking quarantine status..."
if xattr -l "$TARGET_PATH" | grep -q "com.apple.quarantine"; then
    echo "⚠️  App is quarantined by macOS"
    echo "🔧 Removing quarantine attribute..."
    
    xattr -d com.apple.quarantine "$TARGET_PATH"
    
    if [ $? -eq 0 ]; then
        echo "✅ Quarantine removed successfully!"
        echo ""
        echo "🎉 The app should now open without security warnings"
        echo "💡 You can now run the app normally"
        
        if [ "$TARGET_PATH" = "$APP_PATH" ]; then
            echo "   Use: open /Applications/HappyHackingKeybinder.app"
        else
            echo "   Use: open ./HappyHackingKeybinder.app"
        fi
    else
        echo "❌ Failed to remove quarantine. You may need to:"
        echo "   1. Run with sudo: sudo $0"
        echo "   2. Or manually right-click the app and select 'Open'"
    fi
else
    echo "✅ App is not quarantined"
    echo "💡 If you're still seeing warnings, try:"
    echo "   1. Right-click the app and select 'Open'"
    echo "   2. Click 'Open' in the security dialog"
fi

echo ""
echo "📖 For more solutions, see README_GATEKEEPER.md"