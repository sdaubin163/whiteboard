//
//  ContentView.swift
//  whiteboard
//
//  Created by 孙斌 on 2025/8/17.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appModel = AppModel()
    @State private var sidebarOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // 背景
            ModernBackground()
            
            HStack(spacing: 0) {
                // 左侧边栏
                ZStack {
                    // 侧边栏背景
                    GlassPanel()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.leading, 8)
                        .padding(.vertical, 8)
                    
                    VStack(spacing: 16) {
                        // 顶部装饰
                        VStack(spacing: 4) {
                            Circle()
                                .fill(ModernTheme.primaryGradient)
                                .frame(width: 6, height: 6)
                            Circle()
                                .fill(ModernTheme.primaryCyan.opacity(0.6))
                                .frame(width: 4, height: 4)
                            Circle()
                                .fill(ModernTheme.primaryBlue.opacity(0.4))
                                .frame(width: 2, height: 2)
                        }
                        .padding(.top, 8)
                        
                        // 应用按钮
                        VStack(spacing: 12) {
                            ForEach(appModel.webApps) { app in
                                SidebarButton(
                                    icon: app.icon,
                                    isSystemIcon: app.isSystemIcon,
                                    isSelected: appModel.selectedApp?.id == app.id
                                ) {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        appModel.selectedApp = app
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // 底部状态指示器
                        VStack(spacing: 8) {
                            Rectangle()
                                .fill(ModernTheme.primaryCyan.opacity(0.3))
                                .frame(width: 20, height: 1)
                            
                            Circle()
                                .fill(appModel.selectedApp != nil ? ModernTheme.primaryCyan : ModernTheme.secondaryText)
                                .frame(width: 6, height: 6)
                                .animation(.easeInOut(duration: 0.3), value: appModel.selectedApp != nil)
                        }
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 16)
                }
                .frame(width: 80)
                .offset(x: sidebarOffset)
                
                // 右侧主内容区域
                ZStack {
                    // 内容背景
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .background(ModernTheme.darkBackground.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            ModernTheme.primaryCyan.opacity(0.2),
                                            Color.clear,
                                            ModernTheme.primaryBlue.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .padding(.trailing, 8)
                        .padding(.vertical, 8)
                    
                    // WebView 或占位内容
                    Group {
                        if let selectedApp = appModel.selectedApp,
                           let url = URL(string: selectedApp.url) {
                            WebView(url: url)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.trailing, 12)
                                .padding(.vertical, 12)
                        } else {
                            VStack(spacing: 24) {
                                ZStack {
                                    Circle()
                                        .fill(ModernTheme.glowGradient)
                                        .frame(width: 120, height: 120)
                                        .opacity(0.3)
                                    
                                    Image(systemName: "globe")
                                        .font(.system(size: 48, weight: .ultraLight))
                                        .foregroundStyle(ModernTheme.primaryGradient)
                                }
                                
                                VStack(spacing: 8) {
                                    Text("欢迎使用智能工作台")
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .foregroundColor(ModernTheme.primaryText)
                                    
                                    Text("选择左侧应用开始您的工作流程")
                                        .font(.body)
                                        .foregroundColor(ModernTheme.secondaryText)
                                }
                                
                                // 快速启动提示
                                HStack(spacing: 16) {
                                    ForEach(appModel.webApps.prefix(3)) { app in
                                        VStack(spacing: 8) {
                                            Image(systemName: app.icon)
                                                .font(.title2)
                                                .foregroundColor(ModernTheme.accentText)
                                            Text(app.name)
                                                .font(.caption)
                                                .foregroundColor(ModernTheme.secondaryText)
                                        }
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(ModernTheme.cardBackground.opacity(0.3))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(ModernTheme.primaryCyan.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                appModel.selectedApp = app
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 16)
                            }
                        }
                    }
                }
            }
        }
        .frame(minWidth: 1000, minHeight: 700)
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) {
                sidebarOffset = 0
            }
        }
    }
}

#Preview {
    ContentView()
}
