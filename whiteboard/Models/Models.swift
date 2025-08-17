// 
// Models.swift
// whiteboard
//
// 数据模型模块索引文件
//

import SwiftUI

// MARK: - 数据模型模块导出
// 这个文件作为数据模型模块的统一入口点

// 数据模型:
// - AppModel: 应用状态管理，包含 Web 应用列表和当前选中状态
// - WebApp: Web 应用数据结构，包含名称、图标、URL 等信息

// 使用示例:
// import SwiftUI
// 
// struct MyView: View {
//     @StateObject private var appModel = AppModel()
//     
//     var body: some View {
//         VStack {
//             ForEach(appModel.webApps) { app in
//                 Text(app.name)
//             }
//         }
//     }
// }