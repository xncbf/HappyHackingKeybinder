# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HHKB Key Binder is a macOS keyboard remapping utility written in Swift. It intercepts and modifies keyboard events using CGEvent API to provide custom key mappings. The app runs as a menu bar application without a dock icon.

## Key Mappings

- Left Control tap → F16 (for Korean/English toggle)
- Backtick (`) → Backtick in Korean input mode (prevents ₩ conversion)
- Shift + Esc → Tilde (~)

## Build Commands

```bash
# Build both simple executable and app bundle
./build.sh

# Install to Applications folder
./install.sh
# Then select option 1 for app bundle or 2 for simple executable

# Run simple executable directly (for testing)
./HappyHackingKeybinder_simple

# Fix macOS Gatekeeper security warnings
./fix_gatekeeper.sh
```

## Architecture

### Core Components

1. **AppDelegate.swift**: Manages application lifecycle, menu bar UI, and permission handling
   - Handles Accessibility and Input Monitoring permission requests
   - Manages enable/disable state
   - Creates and controls the KeyRemapper instance

2. **KeyRemapper.swift**: Core event handling logic
   - Creates CGEvent tap for intercepting keyboard events
   - Handles three event types: keyDown, keyUp, flagsChanged
   - Implements Control key timeout logic (200ms) to distinguish tap from hold
   - Includes health check timer to recover from event tap failures
   - Korean input source detection for backtick handling

3. **Permission Flow**:
   - App checks permissions on startup
   - Uses `AXIsProcessTrustedWithOptions` for Accessibility
   - Uses `CGRequestListenEventAccess` for Input Monitoring
   - Stores permission check state in UserDefaults to avoid repeated prompts

### Event Processing

The app uses CGEvent tap at session level (`CGSessionEventTap`) with head insertion to intercept events before other applications. Key processing flow:

1. Control key tap detection: Monitors flagsChanged events for keyCode 59
2. Timeout mechanism: 200ms window to detect tap vs. hold
3. Event generation: Creates synthetic F16 events using CGEvent
4. Event blocking: Returns nil to block original Control release event

### Known Issues

- F16 key binding may not work if event tap is disabled by system
- Event tap can be disabled by timeout or user input - app includes recovery mechanism
- Requires app restart after granting permissions
- macOS Gatekeeper warnings due to ad-hoc code signing (see README_GATEKEEPER.md for solutions)

## Debugging

Enable debug output by looking for print statements in:
- Event tap creation/status
- Control tap detection
- Permission checks

## Security Considerations

- Requires Accessibility permission (`kAXTrustedCheckOptionPrompt`)
- Requires Input Monitoring permission (`CGRequestListenEventAccess`)
- Uses ad-hoc code signing for distribution