import Foundation
import IOKit.hid

class HappyHackingKeyboardMonitor {
    
    private let vendorID: Int = 0x04FE  // PFU Limited
    private let productIDs: Set<Int> = [0x0010, 0x0011, 0x0012, 0x0013]  // Various HHK models
    
    private var hidManager: IOHIDManager?
    private var connectedDevices: Set<IOHIDDevice> = []
    
    var isHappyHackingConnected: Bool {
        return !connectedDevices.isEmpty
    }
    
    var onKeyboardStatusChanged: ((Bool) -> Void)?
    
    func startMonitoring() {
        hidManager = IOHIDManagerCreate(kCFAllocatorDefault, 0)
        
        guard let manager = hidManager else { return }
        
        let matchingDict = [
            kIOHIDVendorIDKey: vendorID,
            kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
            kIOHIDDeviceUsageKey: kHIDUsage_GD_Keyboard
        ] as CFDictionary
        
        IOHIDManagerSetDeviceMatching(manager, matchingDict)
        
        IOHIDManagerRegisterDeviceMatchingCallback(manager, { context, result, sender, device in
            let monitor = Unmanaged<HappyHackingKeyboardMonitor>.fromOpaque(context!).takeUnretainedValue()
            monitor.deviceConnected(device)
        }, Unmanaged.passUnretained(self).toOpaque())
        
        IOHIDManagerRegisterDeviceRemovalCallback(manager, { context, result, sender, device in
            let monitor = Unmanaged<HappyHackingKeyboardMonitor>.fromOpaque(context!).takeUnretainedValue()
            monitor.deviceDisconnected(device)
        }, Unmanaged.passUnretained(self).toOpaque())
        
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerOpen(manager, 0)
        
        checkInitialDevices()
    }
    
    private func checkInitialDevices() {
        guard let manager = hidManager else { return }
        
        let deviceSet = IOHIDManagerCopyDevices(manager)
        if let devices = deviceSet as? Set<IOHIDDevice> {
            for device in devices {
                if isHappyHackingKeyboard(device) {
                    connectedDevices.insert(device)
                }
            }
            
            if !connectedDevices.isEmpty {
                onKeyboardStatusChanged?(true)
            }
        }
    }
    
    private func deviceConnected(_ device: IOHIDDevice) {
        if isHappyHackingKeyboard(device) {
            connectedDevices.insert(device)
            onKeyboardStatusChanged?(true)
            
            if let modelName = getDeviceModelName(device) {
                print("Connected: \(modelName)")
            }
        }
    }
    
    private func deviceDisconnected(_ device: IOHIDDevice) {
        if connectedDevices.contains(device) {
            connectedDevices.remove(device)
            onKeyboardStatusChanged?(!connectedDevices.isEmpty)
            
            if let modelName = getDeviceModelName(device) {
                print("Disconnected: \(modelName)")
            }
        }
    }
    
    private func isHappyHackingKeyboard(_ device: IOHIDDevice) -> Bool {
        guard let vendorID = IOHIDDeviceGetProperty(device, kIOHIDVendorIDKey as CFString) as? Int,
              let productID = IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as? Int else {
            return false
        }
        
        return vendorID == self.vendorID && productIDs.contains(productID)
    }
    
    private func getDeviceModelName(_ device: IOHIDDevice) -> String? {
        guard let productID = IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as? Int else {
            return nil
        }
        
        switch productID {
        case 0x0010: return "Happy Hacking Keyboard Professional 2"
        case 0x0011: return "Happy Hacking Keyboard Professional Classic"
        case 0x0012: return "Happy Hacking Keyboard Professional Hybrid"
        case 0x0013: return "Happy Hacking Keyboard Professional Hybrid Type-S"
        default: return "Happy Hacking Keyboard"
        }
    }
    
    deinit {
        if let manager = hidManager {
            IOHIDManagerClose(manager, 0)
        }
    }
}