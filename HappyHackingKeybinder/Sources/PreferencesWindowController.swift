import Cocoa

class PreferencesWindowController: NSWindowController {
    
    private var controlToF16Enabled = true
    private var wonToBacktickEnabled = true
    private var shiftEscToTildeEnabled = true
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "HappyHacking Keybinder Preferences"
        window.center()
        
        self.init(window: window)
        
        setupUI()
        loadPreferences()
    }
    
    private func setupUI() {
        let contentView = NSView(frame: window!.contentRect(forFrameRect: window!.frame))
        
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = NSTextField(labelWithString: "Key Mappings")
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        stackView.addArrangedSubview(titleLabel)
        
        let mappingsStack = NSStackView()
        mappingsStack.orientation = .vertical
        mappingsStack.alignment = .leading
        mappingsStack.spacing = 10
        
        let controlCheckbox = createCheckbox(
            title: "Left Control → F16 (Korean/English toggle)",
            action: #selector(controlMappingChanged(_:)),
            isChecked: controlToF16Enabled
        )
        mappingsStack.addArrangedSubview(controlCheckbox)
        
        let wonCheckbox = createCheckbox(
            title: "₩ → ` (Korean input mode only)",
            action: #selector(wonMappingChanged(_:)),
            isChecked: wonToBacktickEnabled
        )
        mappingsStack.addArrangedSubview(wonCheckbox)
        
        let shiftEscCheckbox = createCheckbox(
            title: "Shift + Esc → ~",
            action: #selector(shiftEscMappingChanged(_:)),
            isChecked: shiftEscToTildeEnabled
        )
        mappingsStack.addArrangedSubview(shiftEscCheckbox)
        
        stackView.addArrangedSubview(mappingsStack)
        
        let infoLabel = NSTextField(wrappingLabelWithString: "Note: Mappings only work when a Happy Hacking keyboard is connected.")
        infoLabel.font = .systemFont(ofSize: 11)
        infoLabel.textColor = .secondaryLabelColor
        stackView.addArrangedSubview(infoLabel)
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
        
        window?.contentView = contentView
    }
    
    private func createCheckbox(title: String, action: Selector, isChecked: Bool) -> NSButton {
        let checkbox = NSButton(checkboxWithTitle: title, target: self, action: action)
        checkbox.state = isChecked ? .on : .off
        return checkbox
    }
    
    @objc private func controlMappingChanged(_ sender: NSButton) {
        controlToF16Enabled = sender.state == .on
        savePreferences()
    }
    
    @objc private func wonMappingChanged(_ sender: NSButton) {
        wonToBacktickEnabled = sender.state == .on
        savePreferences()
    }
    
    @objc private func shiftEscMappingChanged(_ sender: NSButton) {
        shiftEscToTildeEnabled = sender.state == .on
        savePreferences()
    }
    
    private func loadPreferences() {
        controlToF16Enabled = UserDefaults.standard.bool(forKey: "controlToF16Enabled") != false
        wonToBacktickEnabled = UserDefaults.standard.bool(forKey: "wonToBacktickEnabled") != false
        shiftEscToTildeEnabled = UserDefaults.standard.bool(forKey: "shiftEscToTildeEnabled") != false
    }
    
    private func savePreferences() {
        UserDefaults.standard.set(controlToF16Enabled, forKey: "controlToF16Enabled")
        UserDefaults.standard.set(wonToBacktickEnabled, forKey: "wonToBacktickEnabled")
        UserDefaults.standard.set(shiftEscToTildeEnabled, forKey: "shiftEscToTildeEnabled")
    }
}