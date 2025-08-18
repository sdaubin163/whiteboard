# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述
这是一个使用 SwiftUI 构建的 macOS/iOS 应用程序，名为 "whiteboard"（白板应用）。项目使用 Xcode 项目结构，支持单元测试和 UI 测试。

## 架构结构
- **主应用**: `whiteboard/` - 包含主要的 SwiftUI 代码
  - `whiteboardApp.swift` - 应用程序入口点，定义了主要的 App 结构
  - **UI/** - 用户界面模块
    - **Views/** - 视图组件
      - `ContentView.swift` - 主视图组件，现代科技感的智能工作台界面
      - `AppContainerView.swift` - 应用容器视图，支持WebView、文本编辑器和笔记
      - `SettingsView.swift` - 设置界面，配置笔记保存位置和手动保存说明
      - `Views.swift` - 视图模块索引文件
    - **Components/** - 可复用UI组件
      - `SidebarButton.swift` - 侧边栏按钮组件，支持悬停和选中状态
      - `SidebarContainerView.swift` - 左侧按钮区容器，管理应用选择
      - `ContentContainerView.swift` - 右侧内容区容器，支持视图实例隔离
      - `WebView.swift` - Web 视图组件，用于嵌入网页应用
      - `Components.swift` - 组件模块索引文件
    - **Styles/** - 样式和主题
      - `ModernTheme.swift` - 现代科技感主题配色方案
      - `ModernBackground.swift` - 动态背景和玻璃态效果组件
      - `Styles.swift` - 样式模块索引文件
  - **Models/** - 数据模型
    - `AppModel.swift` - 应用数据模型，管理应用列表和容器状态
    - `AppConfig.swift` - 应用配置管理，处理笔记保存位置和应用设置
    - `AppModel+Persistence.swift` - 应用模型持久化扩展
    - `Models.swift` - 数据模型模块索引文件
  - **Managers/** - 管理器模块
    - `AppStateManager.swift` - 应用状态管理器，控制窗口显示/隐藏
    - `GlobalHotKeyManager.swift` - 全局快捷键管理器
    - `MenuBarManager.swift` - 菜单栏管理器
    - `NotePersistenceManager.swift` - 笔记持久化管理器
    - `Managers.swift` - 管理器模块索引文件
  - **Resources/** - 资源管理目录
    - `Icons/icon.icns` - 应用图标文件
    - `ResourceManager.swift` - 资源管理工具类
  - `AppDelegate.swift` - 应用程序委托，管理应用生命周期
  - `Assets.xcassets/` - 应用资源文件（图标、颜色等）
  - `whiteboard.entitlements` - 应用权限配置（包含网络访问权限和文件读写权限）
  - `Info.plist` - 应用信息配置文件
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

## 代码组织原则

### 模块化设计
项目采用模块化的代码组织结构：
- **UI/Views/**: 主要视图组件，包含完整的页面级视图
- **UI/Components/**: 可复用的UI组件，遵循单一职责原则
- **UI/Styles/**: 样式和主题管理，统一视觉风格
- **Models/**: 数据模型和业务逻辑
- **Resources/**: 静态资源管理

### 样式管理
- `ModernTheme.swift`: 定义应用的配色方案、渐变和视觉样式
- `ModernBackground.swift`: 提供动态背景效果和玻璃态UI组件
- 所有样式相关的代码集中在 `UI/Styles/` 目录下

### 组件设计
- 每个组件都是独立的、可复用的
- 支持主题切换和动画效果
- 遵循 SwiftUI 的最佳实践

## 核心功能

### 应用容器系统
- **隔离架构**: 采用完全隔离的容器架构，解决视图状态污染问题
- **懒加载架构**: 只有被访问的应用才会创建容器实例
- **状态保持**: 每个容器维护独立的状态，切换时不丢失数据
- **视图隔离**: 左侧按钮区（SidebarContainerView）和右侧内容区（ContentContainerView）完全分离
- **容器类型**: 
  - IsolatedWebViewContainer（隔离的WebView容器）
  - IsolatedTextEditorContainer（隔离的文本编辑器容器）
  - IsolatedNotesContainer（隔离的笔记容器）

### 笔记管理系统
- **持久化存储**: 笔记保存为JSON格式
- **自定义保存位置**: 用户可以选择笔记保存目录
- **手动保存**: 仅支持Cmd+S快捷键手动保存（已移除自动保存功能）
- **即时保存**: 新建和删除笔记时立即保存
- **权限管理**: 使用安全范围访问和书签机制
- **配置文件位置**: `~/Documents/WhiteboardApp/AppConfig.json`

### 全局快捷键
- **Option + Esc**: 智能切换应用显示/隐藏
  - 应用隐藏 → 显示并激活
  - 应用显示且激活 → 隐藏到菜单栏
  - 应用显示但未激活 → 激活应用
- **Option + Esc + Shift**: 切换并重置到空白页
  - 应用隐藏 → 显示并重置到空白页
  - 应用显示且激活 → 重置后隐藏
  - 应用显示但未激活 → 激活并重置到空白页
- **ESC**: 应用内快捷键，快速隐藏应用
  - 仅在应用处于激活状态时生效
  - 直接隐藏应用到菜单栏
- **实现**: 全局快捷键使用 Carbon 框架，ESC 键使用 NSEvent 本地监听

### 菜单栏模式
- **隐藏行为**: 应用隐藏时从程序坞移除，只在菜单栏显示图标
- **菜单功能**: 显示/隐藏窗口、偏好设置、关于、退出
- **点击行为**: 点击菜单栏图标可切换窗口显示状态

### 侧边栏切换
- **工具栏按钮**: 标题栏左侧的侧边栏切换按钮
- **功能**: 显示/隐藏左侧应用选择区域
- **动画**: 平滑的滑动和透明度过渡效果

### 代理设置系统
- **全局代理**: 支持为整个应用配置HTTP/HTTPS/SOCKS5代理
- **代理类型**: HTTP、HTTPS、SOCKS5三种协议支持
- **认证支持**: 可选的用户名密码认证
- **配置管理**: 代理设置保存在AppConfig.json中
- **实时应用**: 代理设置变更后立即生效
- **连接测试**: 内置代理连接测试功能
- **WebView集成**: WebView组件自动使用配置的代理设置
- **网络请求**: 所有URLSession请求都将通过配置的代理

## 架构改进

### 容器隔离架构 (2024年8月更新)
- **问题解决**: 解决了不同类型视图（WebView与文本编辑器）之间的光标样式污染问题
- **隔离方案**: 采用左右分区设计，每个区域有独立的顶层容器控制
- **实现方式**: 
  - 左侧: `SidebarContainerView` 专门管理应用选择按钮
  - 右侧: `ContentContainerView` 管理内容显示，每个应用类型有独立的隔离容器
  - 每个容器使用唯一的 `.id()` 修饰符强制视图实例隔离
- **技术特点**:
  - 视图实例完全隔离，避免状态污染
  - 支持延迟加载和状态同步
  - 保持原有的懒加载性能优势

### 手动保存架构
- **设计理念**: 移除自动保存功能，避免频繁磁盘写入
- **保存时机**:
  - 手动保存: 用户按 Cmd+S 触发
  - 即时保存: 新建笔记、删除笔记时自动保存
  - 编辑保存: 仅在手动保存时写入磁盘
- **用户体验**: 设置界面明确显示"使用 Cmd+S 手动保存笔记"

## 开发注意事项
- 项目使用现代 Swift Testing 框架进行单元测试
- UI 测试使用传统的 XCTest 框架
- 应用具有现代简洁的设计风格，类似 Xcode 的界面
- 支持系统的浅色/深色模式自动切换
- 遵循标准的 Xcode 项目结构和 SwiftUI 最佳实践
- 代码按功能模块组织，便于维护和扩展
- 使用 AppDelegate 管理应用生命周期和系统集成
- 使用沙盒安全机制，需要用户授权文件访问权限
- 支持macOS设计规范（Cmd+,打开设置，无工具栏设置按钮）

### 架构相关注意事项
- **容器隔离**: 修改容器相关代码时，注意保持左右区域的完全隔离
- **视图实例**: 每个隔离容器必须使用唯一的 `.id()` 修饰符
- **状态管理**: 容器状态通过 `@State` 本地管理，确保状态变化能正确触发视图更新
- **笔记保存**: 不再有自动保存功能，只支持手动保存（Cmd+S）和即时保存（新建/删除）
- **方法命名**: 笔记相关方法已重命名（如 `addNote` 而非 `addNoteAndSave`）

## 构建和打包
### 本地开发打包
```bash
# 使用提供的打包脚本
./archive_project.sh

# 手动构建
xcodebuild archive -project whiteboard.xcodeproj -scheme whiteboard -archivePath ./build/whiteboard.xcarchive
```

### 文件权限配置
- **沙盒权限**: `whiteboard.entitlements` 包含必要的文件访问权限
- **权限说明**: `Info.plist` 包含用户友好的权限说明文本
- **运行时权限**: 应用会请求用户授权访问选定的文件夹