import Foundation
import SwiftUI

// 应用配置管理
class AppConfig: ObservableObject {
    static let shared = AppConfig()
    
    @Published var notesSaveLocation: URL
    @Published var notesAppId: UUID? // 笔记应用的UUID
    @Published var autoSaveInterval: TimeInterval = 30 // 自动保存间隔（秒），默认30秒
    @Published var themeMode: String = "深色" // 主题模式，默认深色
    
    // 代理设置
    @Published var proxyEnabled: Bool = false // 是否启用代理
    @Published var proxyType: String = "HTTP" // 代理类型：HTTP, HTTPS, SOCKS5
    @Published var proxyHost: String = "" // 代理服务器地址
    @Published var proxyPort: Int = 8080 // 代理端口
    @Published var proxyUsername: String = "" // 代理用户名（可选）
    @Published var proxyPassword: String = "" // 代理密码（可选）
    @Published var proxyAuthRequired: Bool = false // 是否需要认证
    
    private let configFileName = "AppConfig.json"
    private var configFileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent("WhiteboardApp").appendingPathComponent(configFileName)
    }
    
    private init() {
        // 默认笔记保存位置：文档目录下的 WhiteboardApp/Notes
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.notesSaveLocation = documentsPath.appendingPathComponent("WhiteboardApp").appendingPathComponent("Notes")
        
        loadConfig()
        createDirectoriesIfNeeded()
        restoreSecurityScopedAccess()
        initializeTheme()
        applyProxySettings()
    }
    
    // 配置数据结构
    private struct ConfigData: Codable {
        let notesSaveLocation: String
        let notesAppId: String? // 笔记应用的UUID字符串
        let autoSaveInterval: TimeInterval // 自动保存间隔（秒）
        let themeMode: String? // 主题模式（可选，向后兼容）
        
        // 代理设置（可选，向后兼容）
        let proxyEnabled: Bool?
        let proxyType: String?
        let proxyHost: String?
        let proxyPort: Int?
        let proxyUsername: String?
        let proxyPassword: String?
        let proxyAuthRequired: Bool?
        
        // 为了向后兼容，保留旧字段但设为可选
        let autoSaveEnabled: Bool?
    }
    
    // 加载配置
    private func loadConfig() {
        do {
            let data = try Data(contentsOf: configFileURL)
            let config = try JSONDecoder().decode(ConfigData.self, from: data)
            
            self.notesSaveLocation = URL(fileURLWithPath: config.notesSaveLocation)
            
            // 加载笔记应用ID
            if let notesAppIdString = config.notesAppId {
                self.notesAppId = UUID(uuidString: notesAppIdString)
            }
            
            // 加载自动保存间隔
            self.autoSaveInterval = config.autoSaveInterval
            
            // 加载主题模式（向后兼容）
            self.themeMode = config.themeMode ?? "深色"
            
            // 加载代理设置（向后兼容）
            self.proxyEnabled = config.proxyEnabled ?? false
            self.proxyType = config.proxyType ?? "HTTP"
            self.proxyHost = config.proxyHost ?? ""
            self.proxyPort = config.proxyPort ?? 8080
            self.proxyUsername = config.proxyUsername ?? ""
            self.proxyPassword = config.proxyPassword ?? ""
            self.proxyAuthRequired = config.proxyAuthRequired ?? false
            
            print("✅ 配置加载成功: \(configFileURL.path)")
        } catch {
            print("📝 使用默认配置，将创建新配置文件: \(error.localizedDescription)")
            saveConfig() // 创建默认配置文件
        }
    }
    
    // 保存配置
    func saveConfig() {
        do {
            let config = ConfigData(
                notesSaveLocation: notesSaveLocation.path,
                notesAppId: notesAppId?.uuidString,
                autoSaveInterval: autoSaveInterval,
                themeMode: themeMode,
                proxyEnabled: proxyEnabled,
                proxyType: proxyType,
                proxyHost: proxyHost,
                proxyPort: proxyPort,
                proxyUsername: proxyUsername,
                proxyPassword: proxyPassword,
                proxyAuthRequired: proxyAuthRequired,
                autoSaveEnabled: nil // 为了向后兼容保留
            )
            
            let data = try JSONEncoder().encode(config)
            
            // 确保目录存在
            let configDir = configFileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
            
            try data.write(to: configFileURL)
            print("💾 配置保存成功: \(configFileURL.path)")
        } catch {
            print("❌ 配置保存失败: \(error.localizedDescription)")
        }
    }
    
    // 创建必要的目录
    private func createDirectoriesIfNeeded() {
        do {
            try FileManager.default.createDirectory(at: notesSaveLocation, withIntermediateDirectories: true)
            print("📁 笔记目录已创建: \(notesSaveLocation.path)")
        } catch {
            print("❌ 创建笔记目录失败: \(error.localizedDescription)")
        }
    }
    
    // 更新笔记保存位置
    func updateNotesSaveLocation(_ newLocation: URL) {
        print("📝 更新笔记保存位置: \(newLocation.path)")
        notesSaveLocation = newLocation
        // 不再自动创建目录，用户选择的目录应该已经存在并且有权限
        saveConfig()
    }
    
    
    // 更新笔记应用ID
    func updateNotesAppId(_ appId: UUID) {
        notesAppId = appId
        saveConfig()
        print("📝 笔记应用ID已更新: \(appId.uuidString)")
    }
    
    // 更新自动保存间隔
    func updateAutoSaveInterval(_ interval: TimeInterval) {
        autoSaveInterval = max(5, min(300, interval)) // 限制在5秒到300秒之间
        saveConfig()
        print("📝 自动保存间隔已更新: \(autoSaveInterval)秒")
        
        // 发送通知以更新现有的容器计时器
        NotificationCenter.default.post(name: .autoSaveIntervalChanged, object: autoSaveInterval)
    }
    
    // 更新主题模式
    func updateThemeMode(_ mode: String) {
        themeMode = mode
        saveConfig()
        print("🎨 主题模式已更新: \(mode)")
        
        // 更新 ModernTheme 的当前模式
        if let themeMode = ModernTheme.ThemeMode(rawValue: mode) {
            ModernTheme.updateTheme(to: themeMode)
        }
    }
    
    // 更新代理设置
    func updateProxySettings(enabled: Bool, type: String, host: String, port: Int, username: String, password: String, authRequired: Bool) {
        proxyEnabled = enabled
        proxyType = type
        proxyHost = host
        proxyPort = port
        proxyUsername = username
        proxyPassword = password
        proxyAuthRequired = authRequired
        saveConfig()
        print("🌐 代理设置已更新: \(enabled ? "启用" : "禁用") - \(host):\(port)")
        
        // 应用代理设置
        applyProxySettings()
    }
    
    // 应用代理设置到系统
    private func applyProxySettings() {
        if proxyEnabled && !proxyHost.isEmpty {
            ProxyManager.shared.configureProxy(
                type: proxyType,
                host: proxyHost,
                port: proxyPort,
                username: proxyAuthRequired ? proxyUsername : nil,
                password: proxyAuthRequired ? proxyPassword : nil
            )
        } else {
            ProxyManager.shared.disableProxy()
        }
    }
    
    // 恢复安全范围访问权限
    private func restoreSecurityScopedAccess() {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "NotesFolderBookmark") else {
            print("📝 没有找到保存的文件夹访问权限")
            return
        }
        
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: [.withSecurityScope, .withoutUI],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            
            if isStale {
                print("⚠️ 文件夹访问权限已过期，需要重新选择")
                return
            }
            
            if url.startAccessingSecurityScopedResource() {
                print("✅ 恢复文件夹访问权限: \(url.path)")
                self.notesSaveLocation = url
                // 注意：这里不停止访问，保持权限直到应用结束
            } else {
                print("❌ 无法恢复文件夹访问权限")
            }
        } catch {
            print("❌ 恢复文件夹访问权限失败: \(error.localizedDescription)")
        }
    }
    
    // 初始化主题
    private func initializeTheme() {
        if let themeMode = ModernTheme.ThemeMode(rawValue: themeMode) {
            ModernTheme.updateTheme(to: themeMode)
            print("🎨 主题初始化完成: \(themeMode)")
            
            // 延迟发送主题变更通知，确保UI已经加载
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: .themeChanged, object: themeMode)
            }
        }
    }
}

// 通知名称扩展
extension Notification.Name {
    static let autoSaveIntervalChanged = Notification.Name("autoSaveIntervalChanged")
    static let appStateManagerReady = Notification.Name("appStateManagerReady")
    static let themeChanged = Notification.Name("themeChanged")
}