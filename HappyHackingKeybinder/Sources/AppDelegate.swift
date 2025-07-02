import Cocoa
import Carbon.HIToolbox

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    var keyRemapper: KeyRemapper!
    var isEnabled = true
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure the app doesn't show in the dock
        NSApp.setActivationPolicy(.accessory)
        
        setupMenuBar()
        
        // Check both accessibility and input monitoring permissions
        let hasAccessibility = checkAccessibilityPermission()
        let hasInputMonitoring = checkInputMonitoringPermission()
        
        if !hasAccessibility || !hasInputMonitoring {
            showPermissionAlert(hasAccessibility: hasAccessibility, hasInputMonitoring: hasInputMonitoring)
            // Continue setup anyway, but functionality will be limited
        }
        
        keyRemapper = KeyRemapper()
        keyRemapper.setEnabled(isEnabled)
        
        startMonitoring()
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        updateMenuBarIcon()
        
        let menu = NSMenu()
        
        let statusMenuItem = NSMenuItem(title: "Status: Enabled", action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let toggleMenuItem = NSMenuItem(title: "Disable", action: #selector(toggleEnabled), keyEquivalent: "")
        menu.addItem(toggleMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func updateMenuBarIcon() {
        if let button = statusItem.button {
            let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
            let symbolName = isEnabled ? "keyboard.fill" : "keyboard"
            
            if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "HappyHacking Keybinder")?.withSymbolConfiguration(config) {
                button.image = image
                button.image?.isTemplate = true
                
                // Make inactive state more transparent
                if !isEnabled {
                    button.alphaValue = 0.5
                } else {
                    button.alphaValue = 1.0
                }
            }
        }
    }
    
    @objc func toggleEnabled() {
        isEnabled.toggle()
        keyRemapper.setEnabled(isEnabled)
        updateMenuBarIcon()
        updateMenuItems()
    }
    
    func updateMenuItems() {
        if let menu = statusItem.menu {
            // Update status text
            if let statusItem = menu.item(at: 0) {
                statusItem.title = "Status: \(isEnabled ? "Enabled" : "Disabled")"
            }
            
            // Update toggle button text
            if let toggleItem = menu.item(at: 2) {
                toggleItem.title = isEnabled ? "Disable" : "Enable"
            }
        }
    }
    
    @objc func showPreferences() {
        let preferencesWindow = PreferencesWindowController()
        preferencesWindow.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func checkAccessibilityPermission() -> Bool {
        // Check without prompting
        return AXIsProcessTrusted()
    }
    
    func checkInputMonitoringPermission() -> Bool {
        // Check input monitoring permission
        return CGPreflightListenEventAccess()
    }
    
    func showPermissionAlert(hasAccessibility: Bool, hasInputMonitoring: Bool) {
        let alert = NSAlert()
        alert.messageText = "Permissions Required"
        
        var message = "HappyHacking Keybinder needs permissions to monitor and remap keys.\n\nPlease grant permission in System Preferences:\n"
        if !hasAccessibility {
            message += "• Security & Privacy > Privacy > Accessibility\n"
        }
        if !hasInputMonitoring {
            message += "• Security & Privacy > Privacy > Input Monitoring\n"
        }
        
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Continue Anyway")
        alert.addButton(withTitle: "Quit")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        } else if response == .alertThirdButtonReturn {
            NSApplication.shared.terminate(nil)
        }
    }
    
    func startMonitoring() {
        keyRemapper.startRemapping()
    }
}