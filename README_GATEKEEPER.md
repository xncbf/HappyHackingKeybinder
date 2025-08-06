# Fixing macOS Gatekeeper Security Warning

## The Problem

When you download and try to run HappyHackingKeybinder, macOS may show this warning:

> "Apple cannot verify that this app is free from malware" (Korean: "Apple은 이 앱에 악성 코드가 없음을 확인할 수 없습니다")

This happens because the app uses ad-hoc code signing instead of a paid Apple Developer certificate.

## Solutions

### Option 1: Manual Override (Recommended for Users)

1. **First time opening the app:**
   - Right-click on `HappyHackingKeybinder.app` 
   - Select "Open" from the context menu
   - Click "Open" in the security dialog

2. **Alternative method:**
   - Go to System Preferences → Security & Privacy → General
   - Look for "HappyHackingKeybinder was blocked..." message
   - Click "Open Anyway"

3. **Command line method:**
   ```bash
   # Remove quarantine attribute
   xattr -d com.apple.quarantine /Applications/HappyHackingKeybinder.app
   ```

### Option 2: Developer Certificate (For Distribution)

If you're building for distribution, you need an Apple Developer account ($99/year):

1. Get Apple Developer certificate
2. The build script will automatically detect and use it
3. For notarization (optional but recommended):
   ```bash
   # After building with Developer ID
   xcrun notarytool submit HappyHackingKeybinder.app --keychain-profile "notarytool-profile" --wait
   xcrun stapler staple HappyHackingKeybinder.app
   ```

### Option 3: Self-Signed Certificate (Advanced)

Create a self-signed certificate for local development:

```bash
# Create certificate
security create-certificate \
  -c "HappyHackingKeybinder Developer" \
  -n "Developer ID Application: HappyHackingKeybinder" \
  -t 1 -d 365 -k ~/Library/Keychains/login.keychain

# Trust the certificate
sudo security add-trusted-cert -d root -r trustRoot -k /Library/Keychains/System.keychain ~/Desktop/cert.cer
```

## Why This Happens

- HappyHackingKeybinder requires low-level system access for keyboard interception
- It needs Accessibility permissions and Input Monitoring permissions
- Without a paid Apple Developer certificate, macOS treats it as potentially unsafe
- This is normal for open-source security/utility apps

## Security Notes

- The app is open source - you can review the code
- It only intercepts specific key combinations (Control, backtick, Shift+Esc)
- No network access or data collection
- Requires explicit user permission for Accessibility features

## Building From Source

If you build from source yourself, the warning is less likely to appear since you're not downloading a "foreign" binary.