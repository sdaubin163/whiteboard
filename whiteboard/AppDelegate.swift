import Foundation
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, ObservableObject {
    var appStateManager: AppStateManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("应用启动中...")
        
        // 确保应用在程序坞中可见
        NSApp.setActivationPolicy(.regular)
        
        // 设置窗口关闭行为
        setupWindowCloseHandling()
        
        // 稍后初始化管理器，确保窗口已创建
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.initializeManagers()
        }
    }
    
    private func initializeManagers() {
        // 初始化应用状态管理器
        appStateManager = AppStateManager(appDelegate: self)
        
        // 初始化代理管理器（通过AppConfig自动初始化）
        _ = ProxyManager.shared
        
        // 强制显示窗口
        self.showMainWindow()
        
        // 发送初始化完成通知
        NotificationCenter.default.post(name: .appStateManagerReady, object: appStateManager)
        
        print("应用启动完成，全局快捷键 Option+Esc 已激活")
    }
    
    private func showMainWindow() {
        DispatchQueue.main.async {
            if let window = NSApp.windows.first {
                print("找到窗口，正在显示并激活...")
                
                // 确保窗口可见并居中
                window.center()
                window.makeKeyAndOrderFront(nil)
                
                // 将窗口移到所有应用程序的前面
                window.orderFrontRegardless()
                
                // 激活应用程序
                NSApp.activate(ignoringOtherApps: true)
                
                // 确保窗口成为关键窗口（获得焦点）
                window.makeKey()
                
                print("窗口已激活")
            } else {
                print("未找到窗口")
                // 如果没有窗口，激活应用
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    @objc func handleWindowClose() {
        appStateManager?.handleWindowClose()
    }
    
    private func setupWindowCloseHandling() {
        // 不再使用通用的窗口关闭通知，因为会被 WebView 意外触发
        // 改为直接在窗口关闭按钮上设置处理逻辑
        print("窗口关闭处理已设置为直接绑定到关闭按钮")
    }
    
    // 防止应用在最后一个窗口关闭时退出
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    // 处理应用重新激活
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        print("应用重新激活，hasVisibleWindows: \(flag)")
        if !flag {
            // 如果没有可见窗口，显示主窗口
            showMainWindow()
        }
        return true
    }
    
    // 应用变为活跃状态
    func applicationDidBecomeActive(_ notification: Notification) {
        print("应用变为活跃状态")
        // 确保窗口可见
        if NSApp.windows.isEmpty {
            print("没有窗口，尝试激活应用")
        } else {
            showMainWindow()
        }
    }
    
    // MARK: - NSWindowDelegate
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        print("🔴 windowShouldClose 被调用 - 这是真正的用户关闭操作")
        // 阻止窗口真正关闭，而是隐藏到菜单栏
        appStateManager?.handleWindowClose()
        return false  // 阻止窗口关闭
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}