//
//  ContentView.swift
//  whiteboard
//
//  Created by 孙斌 on 2025/8/17.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appModel = AppModel()
    @State private var isSidebarVisible = true
    @State private var showingSettings = false
    @State private var keyMonitor: Any?
    @State private var appStateManagerRef: AppStateManager?
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // 左侧按钮区容器
                if isSidebarVisible {
                    SidebarContainerView(
                        appModel: appModel,
                        isSidebarVisible: $isSidebarVisible
                    )
                    
                    // 分隔线
                    Rectangle()
                        .fill(ModernTheme.separatorColor)
                        .frame(width: 1)
                        .opacity(0.5)
                        .transition(.opacity)
                }
                
                // 右侧内容区容器 - 实现完全隔离
                ContentContainerView(appModel: appModel)
                }
        }
        .background(ModernBackground())
        .frame(minWidth: 800, minHeight: 600)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                SidebarToggleButton(isSidebarVisible: $isSidebarVisible)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .resetToBlankPage)) { _ in
            print("📄 ContentView: 收到重置通知，重置到空白页面")
            DispatchQueue.main.async {
                appModel.resetToBlankPage()
            }
        }
        .onAppear {
            setupApp()
            setupEscKeyListener()
        }
        .onDisappear {
            removeEscKeyListener()
        }
        .onReceive(NotificationCenter.default.publisher(for: .openSettings)) { _ in
            showingSettings = true
        }
    }
    
    private func setupApp() {
        print("🚀 初始化应用...")
        appModel.setupNotePersistence()
        
        // 调试：打印当前保存路径
        NotePersistenceManager.shared.debugPrintSavePath()
        
        // 预加载笔记数据
        appModel.preloadNotesData()
        
        // 监听 AppStateManager 初始化完成通知
        NotificationCenter.default.addObserver(
            forName: .appStateManagerReady,
            object: nil,
            queue: .main
        ) { notification in
            if let appStateManager = notification.object as? AppStateManager {
                self.appStateManagerRef = appStateManager
                print("✅ AppStateManager 初始化完成，已缓存引用")
            }
        }
        
        print("✅ 应用初始化完成")
    }
    
    private func setupEscKeyListener() {
        // 移除已存在的监听器
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
        }
        
        // 添加本地键盘事件监听
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 { // ESC 键的 keyCode 是 53
                handleEscKeyPressed()
                return nil // 阻止事件继续传播
            }
            return event // 允许其他键盘事件正常处理
        }
        
        print("⌨️ ESC 键监听器已设置")
    }
    
    private func removeEscKeyListener() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
            print("⌨️ ESC 键监听器已移除")
        }
    }
    
    private func handleEscKeyPressed() {
        // 检查应用是否处于激活状态
        guard NSApp.isActive else {
            print("⌨️ ESC 键被按下，但应用未激活，忽略")
            return
        }
        
        print("⌨️ ESC 键被按下，应用处于激活状态，执行隐藏操作")
        
        // 优先使用缓存的 AppStateManager 引用
        if let appStateManager = appStateManagerRef {
            print("✅ 使用缓存的 AppStateManager 引用")
            appStateManager.hideWindow()
        } else if let appDelegate = NSApp.delegate as? AppDelegate {
            print("🔍 AppDelegate 获取成功")
            if let appStateManager = appDelegate.appStateManager {
                print("✅ AppStateManager 获取成功，使用正常流程")
                appStateManager.hideWindow()
                // 同时缓存引用以便下次使用
                appStateManagerRef = appStateManager
            } else {
                print("❌ AppStateManager 为 nil，可能尚未初始化")
                // 备用方案：模拟 AppStateManager 的隐藏逻辑
                NSApp.windows.forEach { window in
                    window.orderOut(nil)
                }
                // 从程序坞隐藏
                NSApp.setActivationPolicy(.accessory)
                print("✅ 使用备用方案隐藏到菜单栏")
            }
        } else {
            print("❌ 无法获取 AppDelegate")
            // 最基本的备用方案
            NSApp.windows.forEach { window in
                window.orderOut(nil)
            }
            NSApp.setActivationPolicy(.accessory)
            print("✅ 使用最基本备用方案隐藏到菜单栏")
        }
    }
}

#Preview {
    ContentView()
}
