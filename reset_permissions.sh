#!/bin/bash

echo "Resetting permissions for HappyHacking Keybinder..."
echo "This requires administrator privileges."

# Reset accessibility permissions for the app
sudo tccutil reset Accessibility com.happyhacking.keybinder

# Reset input monitoring permissions
sudo tccutil reset PostEvent com.happyhacking.keybinder
sudo tccutil reset ListenEvent com.happyhacking.keybinder

echo ""
echo "Permissions reset complete!"
echo ""
echo "Next steps:"
echo "1. Rebuild the app: ./build.sh"
echo "2. Move the app to /Applications"
echo "3. Launch the app - it will request permissions again"
echo "4. Grant both Accessibility and Input Monitoring permissions in System Preferences"
echo ""
echo "If the app still doesn't work:"
echo "1. Open System Preferences > Security & Privacy > Privacy"
echo "2. Click the lock to make changes"
echo "3. Remove HappyHacking Keybinder from both Accessibility and Input Monitoring"
echo "4. Add it back by clicking the + button and selecting the app"