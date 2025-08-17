# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述
这是一个使用 SwiftUI 构建的 macOS/iOS 应用程序，名为 "whiteboard"（白板应用）。项目使用 Xcode 项目结构，支持单元测试和 UI 测试。

## 架构结构
- **主应用**: `whiteboard/` - 包含主要的 SwiftUI 代码
  - `whiteboardApp.swift` - 应用程序入口点，定义了主要的 App 结构
  - `ContentView.swift` - 主视图组件，现代科技感的智能工作台界面
  - `SidebarButton.swift` - 侧边栏按钮组件，支持悬停和选中状态
  - `WebView.swift` - Web 视图组件，用于嵌入网页应用
  - `AppModel.swift` - 应用数据模型，管理 Web 应用列表
  - `ModernTheme.swift` - 现代科技感主题配色方案
  - `ModernBackground.swift` - 动态背景和玻璃态效果组件
  - `Assets.xcassets/` - 应用资源文件（图标、颜色等）
  - `Resources/` - 资源管理目录
    - `Icons/icon.icns` - 应用图标文件
    - `ResourceManager.swift` - 资源管理工具类
  - `whiteboard.entitlements` - 应用权限配置（包含网络访问权限）
- **测试结构**:
  - `whiteboardTests/` - 单元测试，使用 Swift Testing 框架
  - `whiteboardUITests/` - UI 测试，使用 XCTest 框架

## 开发命令

### 构建和运行
使用 Xcode 构建系统：
```bash
# 在 Xcode 中构建项目
xcodebuild -project whiteboard.xcodeproj -scheme whiteboard build

# 运行应用（需要在 Xcode 中或使用 Simulator）
open whiteboard.xcodeproj
```

### 测试
```bash
# 运行单元测试
xcodebuild test -project whiteboard.xcodeproj -scheme whiteboard -destination 'platform=macOS'

# 运行 UI 测试
xcodebuild test -project whiteboard.xcodeproj -scheme whiteboard -destination 'platform=macOS' -only-testing:whiteboardUITests
```

## 技术栈
- **UI 框架**: SwiftUI
- **测试框架**: 
  - Swift Testing（用于单元测试）
  - XCTest（用于 UI 测试）
- **开发环境**: Xcode
- **目标平台**: macOS（可能支持 iOS，取决于项目配置）

## 开发注意事项
- 项目使用现代 Swift Testing 框架进行单元测试
- UI 测试使用传统的 XCTest 框架
- 当前应用处于初始阶段，主要包含基础的 SwiftUI 视图结构
- 遵循标准的 Xcode 项目结构和 SwiftUI 最佳实践