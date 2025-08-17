import Foundation
import SwiftUI

// 应用配置管理
class AppConfig: ObservableObject {
    static let shared = AppConfig()
    
    @Published var notesSaveLocation: URL
    @Published var autoSaveEnabled = true
    @Published var autoSaveInterval: TimeInterval = 5.0 // 5秒自动保存
    @Published var notesAppId: UUID? // 笔记应用的UUID
    
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
    }
    
    // 配置数据结构
    private struct ConfigData: Codable {
        let notesSaveLocation: String
        let autoSaveEnabled: Bool
        let autoSaveInterval: TimeInterval
        let notesAppId: String? // 笔记应用的UUID字符串
    }
    
    // 加载配置
    private func loadConfig() {
        do {
            let data = try Data(contentsOf: configFileURL)
            let config = try JSONDecoder().decode(ConfigData.self, from: data)
            
            self.notesSaveLocation = URL(fileURLWithPath: config.notesSaveLocation)
            self.autoSaveEnabled = config.autoSaveEnabled
            self.autoSaveInterval = config.autoSaveInterval
            
            // 加载笔记应用ID
            if let notesAppIdString = config.notesAppId {
                self.notesAppId = UUID(uuidString: notesAppIdString)
            }
            
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
                autoSaveEnabled: autoSaveEnabled,
                autoSaveInterval: autoSaveInterval,
                notesAppId: notesAppId?.uuidString
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
    
    // 更新自动保存设置
    func updateAutoSaveSettings(enabled: Bool, interval: TimeInterval) {
        autoSaveEnabled = enabled
        autoSaveInterval = interval
        saveConfig()
        print("⚙️ 自动保存设置已更新: 启用=\(enabled), 间隔=\(interval)秒")
    }
    
    // 更新笔记应用ID
    func updateNotesAppId(_ appId: UUID) {
        notesAppId = appId
        saveConfig()
        print("📝 笔记应用ID已更新: \(appId.uuidString)")
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
}