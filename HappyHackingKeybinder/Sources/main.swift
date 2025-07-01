import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// This is important for menu bar apps
app.setActivationPolicy(.accessory)

app.run()