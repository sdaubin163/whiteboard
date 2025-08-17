import Foundation
import Carbon
import AppKit

class GlobalHotKeyManager: ObservableObject {
    private var hotKeyRef1: EventHotKeyRef?
    private var hotKeyRef2: EventHotKeyRef?
    private let hotKeyIdentifier1 = UInt32(1)
    private let hotKeyIdentifier2 = UInt32(2)
    
    var toggleCallback: (() -> Void)?
    var toggleWithResetCallback: (() -> Void)?
    
    init() {
        setupGlobalHotKey()
    }
    
    deinit {
        unregisterHotKey()
    }
    
    private func setupGlobalHotKey() {
        // 注册第一个快捷键: Option + Escape
        registerHotKey1()
        
        // 注册第二个快捷键: Option + Escape + Shift
        registerHotKey2()
        
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
                manager.handleHotKeyEvent(event: event)
                return OSStatus(noErr)
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            nil
        )
        
        print("全局快捷键已注册:")
        print("- Option + Escape: 切换显示/隐藏")
        print("- Option + Escape + Shift: 切换显示/隐藏并重置到首页")
    }
    
    private func registerHotKey1() {
        // Option + Escape 快捷键
        let modifierFlags = UInt32(optionKey)
        let keyCode = UInt32(kVK_Escape)
        
        var hotKeyID = EventHotKeyID(
            signature: fourCharCodeFrom("htk1"),
            id: hotKeyIdentifier1
        )
        
        let status = RegisterEventHotKey(
            keyCode,
            modifierFlags,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef1
        )
        
        if status != OSStatus(noErr) {
            print("注册快捷键1失败: \(status)")
        }
    }
    
    private func registerHotKey2() {
        // Option + Escape + Shift 快捷键
        let modifierFlags = UInt32(optionKey | shiftKey)
        let keyCode = UInt32(kVK_Escape)
        
        var hotKeyID = EventHotKeyID(
            signature: fourCharCodeFrom("htk2"),
            id: hotKeyIdentifier2
        )
        
        let status = RegisterEventHotKey(
            keyCode,
            modifierFlags,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef2
        )
        
        if status != OSStatus(noErr) {
            print("注册快捷键2失败: \(status)")
        }
    }
    
    private func handleHotKeyEvent(event: EventRef?) {
        guard let event = event else { return }
        
        var hotKeyID = EventHotKeyID()
        let result = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )
        
        guard result == OSStatus(noErr) else { return }
        
        DispatchQueue.main.async {
            switch hotKeyID.id {
            case self.hotKeyIdentifier1:
                print("🔥 Option+Esc: 普通切换")
                self.toggleCallback?()
            case self.hotKeyIdentifier2:
                print("🔥 Option+Esc+Shift: 切换并重置")
                self.toggleWithResetCallback?()
            default:
                break
            }
        }
    }
    
    private func unregisterHotKey() {
        if let hotKeyRef1 = hotKeyRef1 {
            UnregisterEventHotKey(hotKeyRef1)
            self.hotKeyRef1 = nil
        }
        
        if let hotKeyRef2 = hotKeyRef2 {
            UnregisterEventHotKey(hotKeyRef2)
            self.hotKeyRef2 = nil
        }
    }
}

private func fourCharCodeFrom(_ string: String) -> OSType {
    let chars = Array(string.utf8)
    guard chars.count >= 4 else { return 0 }
    return OSType(chars[0]) << 24 | OSType(chars[1]) << 16 | OSType(chars[2]) << 8 | OSType(chars[3])
}