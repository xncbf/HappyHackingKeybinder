# HappyHacking Keybinder for macOS

A lightweight key remapping utility for **all keyboards** on macOS

## Features

- ✅ Works with **any keyboard** (USB, Bluetooth, built-in)
- ✅ Left Control tap → F16 (Korean/English toggle)
- ✅ ` → ` (backtick) in Korean input mode (prevents ₩)
- ✅ Shift + Esc → ~ (tilde)
- ✅ Menu bar status indicator
- ✅ Enable/Disable toggle

## System Requirements

- macOS 11.0 (Big Sur) or later
- Accessibility permission required

## Installation

### Easy Installation
```bash
# Clone the repository
git clone https://github.com/xncbf/HappyHackingKeybinder.git
cd HappyHackingKeybinder

# Run the installer
./install.sh
```

### Manual Installation
```bash
# Build the app
./build.sh

# Install to Applications (choose one):
# Option 1: App Bundle (recommended)
cp -r HappyHackingKeybinder.app /Applications/

# Option 2: Simple Executable (for testing)
./HappyHackingKeybinder_simple
```

## Permissions Setup

1. **Accessibility Permission** (required):
   - Go to System Preferences > Security & Privacy > Privacy > Accessibility
   - Click the lock and enter your password
   - Add HappyHackingKeybinder and check the box

2. The app will automatically request permissions on first launch

## Usage

1. Launch the app from Applications or run the executable
2. Check the keyboard icon in the menu bar
   - **Filled icon**: Key remapping is active
   - **Outline icon**: Key remapping is disabled
3. Click the menu bar icon to toggle enable/disable

## Key Mappings

| Original | → | Result | Description |
|----------|---|---------|-------------|
| Left Control (tap) | → | F16 | Korean/English input toggle |
| ` (backtick) in Korean | → | ` | Prevents ₩ symbol in Korean mode |
| Shift + Esc | → | ~ | Tilde character |

## Troubleshooting

### App Bundle vs Simple Executable
- **App Bundle**: Full macOS app with menu bar icon (recommended)
- **Simple Executable**: Command-line version that works reliably but no GUI

### Accessibility Permission Issues
1. Check System Preferences > Security & Privacy > Privacy > Accessibility
2. Remove and re-add the app if needed
3. Try the simple executable if app bundle doesn't work

### Key Mappings Not Working
1. Check menu bar icon status (filled = active)
2. Verify accessibility permission is granted
3. Try disabling and re-enabling in the menu
4. Restart the app

## License

MIT License