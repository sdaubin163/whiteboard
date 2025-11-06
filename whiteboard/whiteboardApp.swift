//
//  whiteboardApp.swift
//  whiteboard
//
//  Created by 孙斌 on 2025/8/17.
//

import SwiftUI

@main
struct whiteboardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 配置窗口属性
                    configureWindow()
                }
        }
        .windowStyle(.automatic)
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .defaultSize(width: 1000, height: 700)
        .commands {
            // 移除默认的"关闭"菜单项，添加自定义行为
            CommandGroup(replacing: .newItem) {}
            
            // 添加设置菜单
            CommandGroup(after: .appInfo) {
                Button("设置...") {
                    NotificationCenter.default.post(name: .openSettings, object: nil)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
            
            // 添加文件菜单命令
            CommandGroup(after: .newItem) {
                Button("保存笔记") {
                    NotificationCenter.default.post(name: .manualSaveNotes, object: nil)
                }
                .keyboardShortcut("s", modifiers: .command)
            }
        }
    }
    
    func configureWindow() {
        DispatchQueue.main.async {
            if let window = NSApp.windows.first {
                print("配置窗口...")
                window.title = "智能工作台"
//                window.center()
                
                // 设置最小尺寸
                window.minSize = NSSize(width: 800, height: 600)
                
                // 设置窗口代理来处理关闭事件
                window.delegate = appDelegate
                print("✅ 窗口代理已设置，关闭操作将隐藏到菜单栏")
            } else {
                print("ContentView.onAppear: 未找到窗口")
            }
        }
    }
}
