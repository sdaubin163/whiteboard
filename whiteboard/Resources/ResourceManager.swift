import SwiftUI
import Foundation

struct AppResources {
    // MARK: - 图标资源
    struct Icons {
        static let appIcon = "icon"
        
        // 应用内图标
        static let gemini = "sparkles"
        static let chatgpt = "message.circle"
        static let claude = "brain.head.profile"
        static let github = "globe"
        static let stackoverflow = "questionmark.circle"
        static let notion = "doc.text"
        static let figma = "paintbrush"
        static let linear = "line.diagonal"
    }
    
    // MARK: - 资源路径
    struct Paths {
        static let resourcesDirectory = "Resources"
        static let iconsDirectory = "Resources/Icons"
    }
    
    // MARK: - 应用信息
    struct AppInfo {
        static let displayName = "智能工作台"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}