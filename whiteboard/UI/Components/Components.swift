// 
// Components.swift
// whiteboard
//
// UI 组件模块索引文件
//

import SwiftUI

// MARK: - 组件模块导出
// 这个文件作为 UI 组件模块的统一入口点

// 可用组件:
// - SidebarButton: 侧边栏按钮组件，支持悬停和选中状态
// - SidebarToggleButton: 侧边栏切换按钮，用于显示/隐藏侧边栏
// - SidebarContainerView: 左侧按钮区容器，管理应用选择
// - ContentContainerView: 右侧内容区容器，支持视图实例隔离
// - WebView: Web 视图组件，用于嵌入网页应用

// 使用示例:
// import SwiftUI
// 
// struct MyView: View {
//     var body: some View {
//         VStack {
//             SidebarButton(icon: "star", isSelected: true) {
//                 // 按钮点击处理
//             }
//         }
//     }
// }