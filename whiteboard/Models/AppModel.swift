import Foundation
import SwiftUI

// 内容类型枚举
enum ContentType {
    case webView
    case textEditor
    case notes
}

// 应用项目结构
struct AppItem: Identifiable {
    let id: UUID
    let name: String
    let icon: String
    let contentType: ContentType
    let url: String?
    let isSystemIcon: Bool
    
    init(id: UUID? = nil, name: String, icon: String, contentType: ContentType, url: String? = nil, isSystemIcon: Bool = true) {
        self.id = id ?? UUID()
        self.name = name
        self.icon = icon
        self.contentType = contentType
        self.url = url
        self.isSystemIcon = isSystemIcon
    }
}

// 应用容器状态
class AppContainerState: ObservableObject {
    let appId: UUID
    let contentType: ContentType
    
    @Published var isVisible = false
    @Published var lastAccessTime = Date()
    
    // WebView 相关状态
    @Published var webViewURL: URL?
    @Published var isWebViewLoading = false
    @Published var webViewError: Error?
    
    // 文本编辑器相关状态
    @Published var textContent = ""
    @Published var textEditorTitle = "未命名文档"
    
    // 笔记相关状态
    @Published var notes: [Note] = []
    
    init(appId: UUID, contentType: ContentType) {
        self.appId = appId
        self.contentType = contentType
    }
    
}

// 应用模型
class AppModel: ObservableObject {
    @Published var selectedApp: AppItem?
    @Published var containers: [UUID: AppContainerState] = [:]
    
    @Published var apps: [AppItem] = []
    
    init() {
        print("🚀 AppModel 初始化")
        initializeApps()
    }
    
    private func initializeApps() {
        let config = AppConfig.shared
        
        // 如果配置中有保存的笔记应用ID，使用它；否则创建新的
        let notesAppId: UUID
        if let savedNotesAppId = config.notesAppId {
            notesAppId = savedNotesAppId
            print("📝 使用配置中保存的笔记应用ID: \(savedNotesAppId.uuidString)")
        } else {
            notesAppId = UUID()
            config.updateNotesAppId(notesAppId)
            print("📝 创建新的笔记应用ID: \(notesAppId.uuidString)")
        }
        
        // 创建应用列表，笔记应用使用固定ID
        apps = [
            AppItem(id: notesAppId, name: "笔记", icon: "note", contentType: .notes),
            AppItem(name: "Gemini", icon: "sparkles", contentType: .webView, url: "https://gemini.google.com"),
            AppItem(name: "ChatGPT", icon: "message", contentType: .webView, url: "https://chat.openai.com")
        ]
    }
    
    // 获取或创建容器状态（懒加载）
    func getContainerState(for appId: UUID) -> AppContainerState? {
        if let existingState = containers[appId] {
            return existingState
        }
        
        // 找到对应的应用
        guard let app = apps.first(where: { $0.id == appId }) else {
            print("❌ 未找到应用 ID: \(appId)")
            return nil
        }
        
        // 创建新的容器状态
        let containerState = AppContainerState(appId: appId, contentType: app.contentType)
        containers[appId] = containerState
        
        print("🆕 为应用 '\(app.name)' 创建新容器状态")
        
        // 根据内容类型进行特殊初始化
        switch app.contentType {
        case .webView:
            if let urlString = app.url, let url = URL(string: urlString) {
                containerState.webViewURL = url
            }
        case .notes:
            // 加载笔记数据
            loadNotesForContainer(appId)
        case .textEditor:
            break
        }
        
        return containerState
    }
    
    
    // 重置到空白页面
    func resetToBlankPage() {
        print("📄 AppModel: 执行重置到空白页面")
        
        // 隐藏所有容器
        for (_, containerState) in containers {
            containerState.isVisible = false
        }
        
        // 清除选中状态
        selectedApp = nil
        
        print("✅ AppModel: 重置完成，所有容器已隐藏")
    }
}