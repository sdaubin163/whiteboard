import Foundation
import SwiftUI
import AppKit

class AppStateManager: ObservableObject {
    @Published var isWindowVisible = true
    @Published var isInMenuBarMode = false
    
    private var hotKeyManager: GlobalHotKeyManager?
    private var menuBarManager: MenuBarManager?
    private weak var appDelegate: AppDelegate?
    private var isInitialized = false
    
    init(appDelegate: AppDelegate?) {
        self.appDelegate = appDelegate
        
        // 设置初始状态
        isWindowVisible = true
        isInMenuBarMode = false
        
        print("AppStateManager 初始化开始")
        setupManagers()
        
        // 延迟标记为已初始化，避免初始化期间的意外切换
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isInitialized = true
            print("AppStateManager 初始化完成")
        }
    }
    
    private func setupManagers() {
        // 初始化全局快捷键管理器
        hotKeyManager = GlobalHotKeyManager()
        hotKeyManager?.toggleCallback = { [weak self] in
            self?.toggleWindowVisibility()
        }
        hotKeyManager?.toggleWithResetCallback = { [weak self] in
            self?.toggleWindowVisibilityWithReset()
        }
        
        // 初始化菜单栏管理器
        menuBarManager = MenuBarManager(appDelegate: appDelegate)
        menuBarManager?.toggleCallback = { [weak self] in
            self?.toggleWindowVisibility()
        }
    }
    
    func toggleWindowVisibility() {
        // 防止在初始化期间意外切换
        guard isInitialized else {
            print("⚠️ AppStateManager 尚未完全初始化，忽略切换请求")
            return
        }
        
        let isAppActive = NSApp.isActive
        print("🔄 切换窗口可见性 - 当前状态: \(isWindowVisible ? "可见" : "隐藏"), 应用激活状态: \(isAppActive ? "激活" : "未激活")")
        
        DispatchQueue.main.async {
            if self.isWindowVisible {
                // 窗口可见时，检查应用是否激活
                if isAppActive {
                    // 应用激活状态下，执行隐藏操作
                    print("➡️ 应用已激活，执行隐藏操作")
                    self.hideWindow()
                } else {
                    // 应用未激活状态下，激活应用
                    print("➡️ 应用未激活，激活应用")
                    self.activateApplication()
                }
            } else {
                print("➡️ 执行显示操作")
                self.showWindow()
            }
        }
    }
    
    func toggleWindowVisibilityWithReset() {
        // 防止在初始化期间意外切换
        guard isInitialized else {
            print("⚠️ AppStateManager 尚未完全初始化，忽略切换请求")
            return
        }
        
        let isAppActive = NSApp.isActive
        print("🔄 切换窗口可见性并重置 - 当前状态: \(isWindowVisible ? "可见" : "隐藏"), 应用激活状态: \(isAppActive ? "激活" : "未激活")")
        
        DispatchQueue.main.async {
            if self.isWindowVisible {
                // 窗口可见时，检查应用是否激活
                if isAppActive {
                    // 应用激活状态下，先重置到空白页再隐藏
                    print("📄 重置到空白页面")
                    NotificationCenter.default.post(name: .resetToBlankPage, object: nil)
                    
                    // 稍微延迟后隐藏窗口，确保重置操作完成
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("➡️ 执行隐藏操作")
                        self.hideWindow()
                    }
                } else {
                    // 应用未激活状态下，激活应用并重置到空白页
                    print("➡️ 应用未激活，激活应用并重置到空白页")
                    self.activateApplication()
                    
                    // 激活后重置到空白页
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("📄 重置到空白页面")
                        NotificationCenter.default.post(name: .resetToBlankPage, object: nil)
                    }
                }
            } else {
                // 如果窗口当前隐藏，先显示窗口，然后重置到空白页
                print("➡️ 执行显示操作")
                self.showWindow()
                
                // 显示窗口后立即重置到空白页
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    print("📄 AppStateManager: 准备发送重置通知")
                    NotificationCenter.default.post(name: .resetToBlankPage, object: nil)
                    print("📄 AppStateManager: 重置通知已发送")
                }
            }
        }
    }
    
    func hideWindow() {
        // 隐藏所有窗口
        NSApp.windows.forEach { window in
            window.orderOut(nil)
        }
        
        // 从程序坞隐藏
        NSApp.setActivationPolicy(.accessory)
        
        isWindowVisible = false
        isInMenuBarMode = true
        
        // 更新菜单项标题
        menuBarManager?.updateMenuItemTitle(isWindowVisible: false)
        
        print("应用已隐藏到菜单栏")
    }
    
    private func showWindow() {
        // 恢复到程序坞
        NSApp.setActivationPolicy(.regular)
        
        // 显示并激活主窗口
        if let window = NSApp.windows.first {
            // 确保窗口可见
            window.makeKeyAndOrderFront(nil)
            
            // 将窗口移到所有应用程序的前面
            window.orderFrontRegardless()
            
            // 激活应用程序
            NSApp.activate(ignoringOtherApps: true)
            
            // 确保窗口成为关键窗口（获得焦点）
            window.makeKey()
            
            print("窗口已显示并激活")
        } else {
            print("未找到窗口")
        }
        
        isWindowVisible = true
        isInMenuBarMode = false
        
        // 更新菜单项标题
        menuBarManager?.updateMenuItemTitle(isWindowVisible: true)
        
        print("应用已从菜单栏恢复")
    }
    
    private func activateApplication() {
        // 激活应用但不显示窗口（窗口已经可见）
        if let window = NSApp.windows.first {
            // 将窗口移到所有应用程序的前面
            window.orderFrontRegardless()
            
            // 激活应用程序
            NSApp.activate(ignoringOtherApps: true)
            
            // 确保窗口成为关键窗口（获得焦点）
            window.makeKey()
            
            print("应用已激活")
        } else {
            print("未找到窗口进行激活")
        }
    }
    
    // 处理窗口关闭事件
    func handleWindowClose() {
        print("🔴 handleWindowClose 被调用")
        
        // 防止在初始化期间意外处理关闭事件
        guard isInitialized else {
            print("⚠️ AppStateManager 尚未完全初始化，忽略窗口关闭事件")
            return
        }
        
        print("➡️ 处理窗口关闭事件，隐藏到菜单栏")
        // 当用户点击关闭按钮时，隐藏到菜单栏而不是退出
        hideWindow()
    }
    
    // 完全退出应用
    func quitApplication() {
        NSApp.terminate(nil)
    }
}