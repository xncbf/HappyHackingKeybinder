import Cocoa
import Carbon.HIToolbox

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    var keyboardMonitor: HappyHackingKeyboardMonitor!
    var keyRemapper: KeyRemapper!
    var isEnabled = true
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure the app doesn't show in the dock
        NSApp.setActivationPolicy(.accessory)
        
        setupMenuBar()
        
        // Check accessibility permission first
        if !checkAccessibilityPermission() {
            showAccessibilityAlert()
            // Continue setup anyway, but functionality will be limited
        }
        
        keyboardMonitor = HappyHackingKeyboardMonitor()
        keyRemapper = KeyRemapper()
        
        keyboardMonitor.onKeyboardStatusChanged = { [weak self] isConnected in
            DispatchQueue.main.async {
                self?.updateMenuBarIcon(isConnected: isConnected)
                self?.keyRemapper.setEnabled(isConnected && (self?.isEnabled ?? false))
            }
        }
        
        startMonitoring()
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        updateMenuBarIcon(isConnected: false)
        
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
    
    func updateMenuBarIcon(isConnected: Bool) {
        if let button = statusItem.button {
            let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
            let symbolName = isConnected && isEnabled ? "keyboard.fill" : "keyboard"
            
            if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "HappyHacking Keybinder")?.withSymbolConfiguration(config) {
                button.image = image
                button.image?.isTemplate = true
                
                // Make inactive state more transparent
                if !(isConnected && isEnabled) {
                    button.alphaValue = 0.5
                } else {
                    button.alphaValue = 1.0
                }
            }
        }
    }
    
    @objc func toggleEnabled() {
        isEnabled.toggle()
        keyRemapper.setEnabled(keyboardMonitor.isHappyHackingConnected && isEnabled)
        updateMenuBarIcon(isConnected: keyboardMonitor.isHappyHackingConnected)
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
    
    func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "HappyHacking Keybinder needs accessibility permission to monitor and remap keys.\n\nPlease grant permission in System Preferences > Security & Privacy > Privacy > Accessibility."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Quit")
        
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        } else {
            NSApplication.shared.terminate(nil)
        }
    }
    
    func startMonitoring() {
        keyboardMonitor.startMonitoring()
        keyRemapper.startRemapping()
    }
}