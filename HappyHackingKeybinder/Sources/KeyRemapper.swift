import Cocoa
import Carbon.HIToolbox

class KeyRemapper {
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isEnabled = false
    private var permissionRequired = false
    
    private var lastControlPressTime: Date?
    private var isControlModifierUsed = false
    private let controlKeyTimeout: TimeInterval = 0.2  // 200ms
    private var healthCheckTimer: Timer?
    
    func needsAccessibilityPermission() -> Bool {
        return permissionRequired
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        print("KeyRemapper setEnabled: \(enabled)")
        
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
        
        // 먼저 listenOnly로 시도해서 입력 모니터링 권한 트리거
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
            print("Failed to create event tap - may need accessibility permission")
            permissionRequired = true
            return
        }
        
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        
        eventTap = tap
        
        // 건강 상태 체크 타이머 시작 (30초마다)
        healthCheckTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.performHealthCheck()
        }
    }
    
    private func removeEventTap() {
        healthCheckTimer?.invalidate()
        healthCheckTimer = nil
        
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
        // 이벤트 탭이 비활성화된 경우 재활성화
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap = eventTap {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
            return Unmanaged.passRetained(event)
        }
        
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
                    
                    // F16 키 이벤트를 직접 생성해서 전송
                    if let f16Event = CGEvent(keyboardEventSource: nil, virtualKey: 106, keyDown: true) {
                        f16Event.post(tap: .cghidEventTap)
                        
                        if let f16UpEvent = CGEvent(keyboardEventSource: nil, virtualKey: 106, keyDown: false) {
                            f16UpEvent.post(tap: .cghidEventTap)
                        }
                    }
                    
                    // 원본 컨트롤 release 이벤트를 차단
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
        
        // 한글 입력 모드에서 백틱(`) 키를 백틱으로 유지 (₩ 방지)
        if keyCode == 50 && isKoreanInputSource() {  // ` key in Korean mode
            // 백틱 문자를 직접 입력
            let source = CGEventSource(stateID: .hidSystemState)
            if let textEvent = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true) {
                textEvent.keyboardSetUnicodeString(stringLength: 1, unicodeString: [0x0060]) // 백틱 유니코드
                return Unmanaged.passRetained(textEvent)
            }
        }
        
        if keyCode == 93 && isKoreanInputSource() {  // ₩ key in Korean mode
            if let backtickEvent = CGEvent(keyboardEventSource: nil, virtualKey: 50, keyDown: true) {
                backtickEvent.flags = flags
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
        
        // 한글 입력 모드에서 백틱(`) keyUp은 무시 (keyDown에서 처리됨)
        if keyCode == 50 && isKoreanInputSource() {  // ` key in Korean mode
            return nil // keyUp 이벤트 차단
        }
        
        if keyCode == 93 && isKoreanInputSource() {  // ₩ key in Korean mode
            if let backtickEvent = CGEvent(keyboardEventSource: nil, virtualKey: 50, keyDown: false) {
                backtickEvent.flags = flags
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
    
    private func performHealthCheck() {
        guard let tap = eventTap else { return }
        
        // 이벤트 탭이 여전히 활성화되어 있는지 확인
        if !CGEvent.tapIsEnabled(tap: tap) {
            print("Event tap was disabled, re-enabling...")
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        
        // 컨트롤 키 상태 리셋 (스턱 방지)
        if let lastPress = lastControlPressTime,
           Date().timeIntervalSince(lastPress) > 5.0 {  // 5초 이상 경과시
            lastControlPressTime = nil
            isControlModifierUsed = false
        }
    }
    
    deinit {
        removeEventTap()
        lastControlPressTime = nil
    }
}