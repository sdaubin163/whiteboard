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
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // 左侧边栏
                if isSidebarVisible {
                    VStack(spacing: 0) {
                        // 侧边栏内容
                        VStack(spacing: 8) {
                            // 应用按钮
                            ForEach(appModel.apps) { app in
                                SidebarButton(
                                    icon: app.icon,
                                    isSystemIcon: app.isSystemIcon,
                                    isSelected: appModel.selectedApp?.id == app.id
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        appModel.selectAppWithPersistence(app)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 8)
                    }
                    .frame(width: 48)
                    .background(SidebarPanel())
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    
                    // 分隔线
                    Rectangle()
                        .fill(ModernTheme.separatorColor)
                        .frame(width: 1)
                        .opacity(0.5)
                        .transition(.opacity)
                }
                
                // 右侧主内容区域 - 只创建已被访问的容器
                ZStack {
                    // 只为已创建的容器创建视图（懒加载）
                    ForEach(Array(appModel.containers.keys), id: \.self) { appId in
                        if let app = appModel.apps.first(where: { $0.id == appId }),
                           let containerState = appModel.getContainerState(for: appId) {
                            AppContainerView(app: app, containerState: containerState)
                                .opacity(appModel.selectedApp?.id == app.id ? 1 : 0)
                                .allowsHitTesting(appModel.selectedApp?.id == app.id)
                                .animation(.easeInOut(duration: 0.3), value: appModel.selectedApp?.id)
                        }
                    }
                    
                    // 占位内容（当没有选中应用时显示）
                    if appModel.selectedApp == nil {
                        VStack(spacing: 32) {
                            Image(systemName: "square.stack.3d.up")
                                .font(.system(size: 64, weight: .ultraLight))
                                .foregroundColor(ModernTheme.secondaryText)
                            
                            VStack(spacing: 8) {
                                Text("选择一个应用开始使用")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(ModernTheme.primaryText)
                                
                                Text("从左侧选择应用访问网页、编辑文档或使用工具")
                                    .font(.body)
                                    .foregroundColor(ModernTheme.secondaryText)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(ModernTheme.contentBackground)
                        .transition(.opacity)
                    }
                }
                .background(ContentPanel())
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
}

#Preview {
    ContentView()
}
