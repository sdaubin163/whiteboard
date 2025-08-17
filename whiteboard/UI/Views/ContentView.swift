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
        
        // 获取 AppStateManager 并执行隐藏操作
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.appStateManager?.hideWindow()
        } else {
            print("❌ 无法获取 AppStateManager")
        }
    }
}

#Preview {
    ContentView()
}
