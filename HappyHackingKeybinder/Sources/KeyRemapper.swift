import Cocoa
import Carbon.HIToolbox

class KeyRemapper {
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isEnabled = false
    
    private var lastControlPressTime: Date?
    private var isControlModifierUsed = false
    private let controlKeyTimeout: TimeInterval = 0.2  // 200ms
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        
        if enabled && eventTap == nil {
            createEventTap()
        } else if !enabled && eventTap != nil {
            removeEventTap()
        }
    }
    
    func startRemapping() {
        if isEnabled {
            createEventTap()
        }
    }
    
    private func createEventTap() {
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { proxy, type, event, refcon in
                let remapper = Unmanaged<KeyRemapper>.fromOpaque(refcon!).takeUnretainedValue()
                return remapper.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("Failed to create event tap")
            return
        }
        
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        
        eventTap = tap
    }
    
    private func removeEventTap() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            }
            eventTap = nil
            runLoopSource = nil
        }
    }
    
    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard isEnabled else {
            return Unmanaged.passRetained(event)
        }
        
        switch type {
        case .flagsChanged:
            return handleFlagsChanged(event: event)
        case .keyDown:
            return handleKeyDown(event: event)
        case .keyUp:
            return handleKeyUp(event: event)
        default:
            return Unmanaged.passRetained(event)
        }
    }
    
    private func handleFlagsChanged(event: CGEvent) -> Unmanaged<CGEvent>? {
        let flags = event.flags
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        
        if keyCode == 59 {  // Left Control
            if flags.contains(.maskControl) {
                lastControlPressTime = Date()
                isControlModifierUsed = false
            } else {
                if let pressTime = lastControlPressTime,
                   Date().timeIntervalSince(pressTime) < controlKeyTimeout,
                   !isControlModifierUsed {
                    
                    if let f16Event = CGEvent(keyboardEventSource: nil, virtualKey: 106, keyDown: true) {
                        f16Event.post(tap: .cghidEventTap)
                        
                        if let f16UpEvent = CGEvent(keyboardEventSource: nil, virtualKey: 106, keyDown: false) {
                            f16UpEvent.post(tap: .cghidEventTap)
                        }
                    }
                    
                    return nil
                }
                lastControlPressTime = nil
            }
        }
        
        return Unmanaged.passRetained(event)
    }
    
    private func handleKeyDown(event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags
        
        if flags.contains(.maskControl) {
            isControlModifierUsed = true
        }
        
        if keyCode == 53 && flags.contains(.maskShift) {  // Esc with Shift
            if let tildeEvent = CGEvent(keyboardEventSource: nil, virtualKey: 50, keyDown: true) {
                tildeEvent.flags = .maskShift
                return Unmanaged.passRetained(tildeEvent)
            }
        }
        
        if keyCode == 93 && isKoreanInputSource() {  // ₩ key in Korean mode
            if let backtickEvent = CGEvent(keyboardEventSource: nil, virtualKey: 50, keyDown: true) {
                backtickEvent.flags = []
                return Unmanaged.passRetained(backtickEvent)
            }
        }
        
        return Unmanaged.passRetained(event)
    }
    
    private func handleKeyUp(event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags
        
        if keyCode == 53 && flags.contains(.maskShift) {  // Esc with Shift
            if let tildeEvent = CGEvent(keyboardEventSource: nil, virtualKey: 50, keyDown: false) {
                tildeEvent.flags = .maskShift
                return Unmanaged.passRetained(tildeEvent)
            }
        }
        
        if keyCode == 93 && isKoreanInputSource() {  // ₩ key in Korean mode
            if let backtickEvent = CGEvent(keyboardEventSource: nil, virtualKey: 50, keyDown: false) {
                backtickEvent.flags = []
                return Unmanaged.passRetained(backtickEvent)
            }
        }
        
        return Unmanaged.passRetained(event)
    }
    
    private func isKoreanInputSource() -> Bool {
        guard let inputSource = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else {
            return false
        }
        
        guard let sourceIDPtr = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID) else {
            return false
        }
        
        let sourceID = Unmanaged<CFString>.fromOpaque(sourceIDPtr).takeUnretainedValue() as String
        
        return sourceID.contains("Korean") || sourceID.contains("2-Set") || sourceID.contains("3-Set")
    }
}