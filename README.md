# HappyHacking Keybinder for macOS

A lightweight key remapping utility exclusively for Happy Hacking keyboards

## Features

- ✅ Auto-detect Happy Hacking keyboards
- ✅ Left Control tap → F16 (Korean/English toggle)
- ✅ ₩ → ` in Korean input mode
- ✅ Shift + Esc → ~ (tilde)
- ✅ Menu bar status indicator
- ✅ Auto-disable when using other keyboards

## Supported Keyboards

- Happy Hacking Keyboard Professional 2
- Happy Hacking Keyboard Professional Classic
- Happy Hacking Keyboard Professional Hybrid
- Happy Hacking Keyboard Professional Hybrid Type-S

## System Requirements

- macOS 11.0 (Big Sur) or later
- Accessibility permission required

## Build Instructions

```bash
# Navigate to project directory
cd HappyHackingKeybinder

# Build
swift build -c release

# Run the app
.build/release/HappyHackingKeybinder
```

## Installation

1. Copy the built app to Applications folder
2. Grant accessibility permission on first launch
3. Add to Login Items for auto-start (optional)

## Usage

1. Automatically activates when Happy Hacking keyboard is connected
2. Check status via menu bar icon
3. Toggle individual mappings in Preferences

## Troubleshooting

### Accessibility Permission Issues
Check app permissions in System Preferences > Security & Privacy > Privacy > Accessibility

### Key Mappings Not Working
1. Check menu bar icon (filled keyboard = active)
2. Verify Happy Hacking keyboard is properly connected
3. Restart the app

## License

MIT License