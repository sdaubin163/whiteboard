# Repository Guidelines

本指南为 whiteboard macOS 应用的贡献者速览，涵盖结构、构建、测试、风格与协作规范。请在提交改动前快速过一遍并对照执行。

## Project Structure & Module Organization
- `whiteboard/`: 应用源码（Swift/SwiftUI）。子目录：
  - `Managers/` 业务与系统管理（如窗口、存储、网络）。
  - `Models/` 领域模型与数据结构。
  - `UI/` 视图与组件（SwiftUI）。
  - `Resources/` 本地资源与辅助脚本；`Assets.xcassets` 资源目录。
- `whiteboardTests/`: 单元测试（XCTest）。
- `whiteboardUITests/`: UI 测试（XCTest UI）。
- `whiteboard.xcodeproj/`: Xcode 工程。
- `build/`: 本地构建产物（由脚本生成）。
- 其他：`export_options.plist`（归档配置）、`PROXY_SETUP_GUIDE.md`（网络代理说明）。

## Build, Test, and Development Commands
- 构建（Debug，默认 scheme）：
```bash
./build_project.sh
```
- 本地打包并运行（Release，生成 `whiteboard.app`）：
```bash
./package_local.sh
open whiteboard.app
```
- 使用 Xcode 打开工程与运行：
```bash
open whiteboard.xcodeproj
```
- 命令行测试（XCTest）：
```bash
xcodebuild -project whiteboard.xcodeproj -scheme whiteboard test
```
- 清理：
```bash
xcodebuild -project whiteboard.xcodeproj -scheme whiteboard clean
```

## Coding Style & Naming Conventions
- 语言：Swift 5+；遵循 Swift API Design Guidelines。
- 缩进：4 spaces；行长建议 ≤ 120。
- 命名：`PascalCase`（类型/枚举），`camelCase`（变量/函数），常量优先 `let`。
- 文件组织：功能聚合优先；公共协议放 `Managers/` 或 `Models/` 近邻。
- 格式化：使用 Xcode 内置格式化（无强制第三方 linter）。

## Testing Guidelines
- 框架：XCTest；测试放在 `whiteboardTests/` 与 `whiteboardUITests/`。
- 命名：测试文件 `FooTests.swift`；方法 `test_<caseDescription>()`。
- 覆盖率：核心模块（Managers/Models）建议 ≥ 70%，提交重大变更需附新增测试。
- 运行：见上文 `xcodebuild ... test`，或在 Xcode Test Navigator 中运行。

## Commit & Pull Request Guidelines
- 现状：历史提交以简短中文为主，格式不统一。
- 建议采用 Conventional Commits，例如：
  - `feat(ui): add toolbar actions`
  - `fix(storage): prevent note loss on quit`
- PR 要求：
  1) 说明动机与变更点；2) 关联 Issue；3) 截图/录屏（UI 变更）；4) 测试通过与影响面说明；5) 无多余文件（如本地 `.app`）。

## Security & Configuration Tips
- 权限：`Info.plist` 与 `whiteboard.entitlements` 已声明文件访问；新增能力需最小化授权并说明用途。
- 构建配置：归档请参考 `export_options.plist`；网络代理见 `PROXY_SETUP_GUIDE.md`。
- 敏感信息：切勿提交证书、密钥或个人配置。

