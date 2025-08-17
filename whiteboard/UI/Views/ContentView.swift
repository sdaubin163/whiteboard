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
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // 左侧边栏
                if isSidebarVisible {
                    VStack(spacing: 0) {
                        // 侧边栏内容
                        VStack(spacing: 8) {
                            // 应用按钮
                            ForEach(appModel.webApps) { app in
                                SidebarButton(
                                    icon: app.icon,
                                    isSystemIcon: app.isSystemIcon,
                                    isSelected: appModel.selectedApp?.id == app.id
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        appModel.selectedApp = app
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
                
                // 右侧主内容区域
                VStack(spacing: 0) {
                    // WebView 或占位内容
                    if let selectedApp = appModel.selectedApp,
                       let url = URL(string: selectedApp.url) {
                        WebView(url: url)
                    } else {
                        VStack(spacing: 32) {
                            Image(systemName: "globe")
                                .font(.system(size: 64, weight: .ultraLight))
                                .foregroundColor(ModernTheme.secondaryText)
                            
                            VStack(spacing: 8) {
                                Text("选择一个应用开始使用")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(ModernTheme.primaryText)
                                
                                Text("从左侧选择一个应用来浏览网页")
                                    .font(.body)
                                    .foregroundColor(ModernTheme.secondaryText)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(ModernTheme.contentBackground)
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
    }
}

#Preview {
    ContentView()
}
