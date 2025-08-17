import Foundation
import Carbon
import AppKit

class GlobalHotKeyManager: ObservableObject {
    private var hotKeyRef: EventHotKeyRef?
    private let hotKeyIdentifier = UInt32(1)
    
    var toggleCallback: (() -> Void)?
    
    init() {
        setupGlobalHotKey()
    }
    
    deinit {
        unregisterHotKey()
    }
    
    private func setupGlobalHotKey() {
        // Option + Escape 快捷键
        let modifierFlags = UInt32(optionKey)
        let keyCode = UInt32(kVK_Escape)
        
        var hotKeyID = EventHotKeyID(
            signature: fourCharCodeFrom("htk1"),
            id: hotKeyIdentifier
        )
        
        let status = RegisterEventHotKey(
            keyCode,
            modifierFlags,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status != OSStatus(noErr) {
            print("注册全局快捷键失败: \(status)")
            return
        }
        
        // 安装事件处理器
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed)
        )
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, event, userData) -> OSStatus in
                guard let userData = userData else { return OSStatus(eventNotHandledErr) }
                let manager = Unmanaged<GlobalHotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                manager.handleHotKey()
                return OSStatus(noErr)
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            nil
        )
        
        print("全局快捷键已注册: Option + Escape")
    }
    
    private func handleHotKey() {
        DispatchQueue.main.async {
            self.toggleCallback?()
        }
    }
    
    private func unregisterHotKey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }
}

private func fourCharCodeFrom(_ string: String) -> OSType {
    let chars = Array(string.utf8)
    guard chars.count >= 4 else { return 0 }
    return OSType(chars[0]) << 24 | OSType(chars[1]) << 16 | OSType(chars[2]) << 8 | OSType(chars[3])
}