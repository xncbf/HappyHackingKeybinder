import Cocoa
import Carbon.HIToolbox

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    var keyboardMonitor: HappyHackingKeyboardMonitor!
    var keyRemapper: KeyRemapper!
    var isEnabled = true
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        
        keyboardMonitor = HappyHackingKeyboardMonitor()
        keyRemapper = KeyRemapper()
        
        keyboardMonitor.onKeyboardStatusChanged = { [weak self] isConnected in
            DispatchQueue.main.async {
                self?.updateMenuBarIcon(isConnected: isConnected)
                self?.keyRemapper.setEnabled(isConnected && (self?.isEnabled ?? false))
            }
        }
        
        if !checkAccessibilityPermission() {
            showAccessibilityAlert()
        } else {
            startMonitoring()
        }
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateMenuBarIcon(isConnected: false)
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Toggle", action: #selector(toggleEnabled), keyEquivalent: ""))
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
            button.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "HappyHacking Keybinder")?.withSymbolConfiguration(config)
        }
    }
    
    @objc func toggleEnabled() {
        isEnabled.toggle()
        keyRemapper.setEnabled(keyboardMonitor.isHappyHackingConnected && isEnabled)
        updateMenuBarIcon(isConnected: keyboardMonitor.isHappyHackingConnected)
    }
    
    @objc func showPreferences() {
        let preferencesWindow = PreferencesWindowController()
        preferencesWindow.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func checkAccessibilityPermission() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: false]
        return AXIsProcessTrustedWithOptions(options)
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