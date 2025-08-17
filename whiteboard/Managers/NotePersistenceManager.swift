import Foundation
import SwiftUI

// 笔记持久化管理器
class NotePersistenceManager: ObservableObject {
    static let shared = NotePersistenceManager()
    
    private let config = AppConfig.shared
    private var autoSaveTimer: Timer?
    
    private init() {
        setupAutoSave()
    }
    
    deinit {
        autoSaveTimer?.invalidate()
    }
    
    // 设置自动保存
    private func setupAutoSave() {
        autoSaveTimer?.invalidate()
        
        guard config.autoSaveEnabled else { return }
        
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: config.autoSaveInterval, repeats: true) { _ in
            self.saveAllNotes()
        }
        
        print("⏰ 自动保存已启用，间隔: \(config.autoSaveInterval)秒")
    }
    
    // 重新配置自动保存
    func reconfigureAutoSave() {
        setupAutoSave()
    }
    
    // 获取笔记文件URL
    private func noteFileURL(for appId: UUID) -> URL {
        return config.notesSaveLocation.appendingPathComponent("\(appId.uuidString).json")
    }
    
    // 保存单个容器的笔记
    func saveNotes(for appId: UUID, notes: [Note]) {
        let fileURL = noteFileURL(for: appId)
        
        let saveDirectory = config.notesSaveLocation
        var needsSecurityScope = false
        var securityScopedURL: URL?
        
        // 检查是否需要安全范围访问
        if let bookmarkData = UserDefaults.standard.data(forKey: "NotesFolderBookmark") {
            do {
                var isStale = false
                let bookmarkURL = try URL(
                    resolvingBookmarkData: bookmarkData,
                    options: [.withSecurityScope, .withoutUI],
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )
                
                if !isStale && bookmarkURL.path == saveDirectory.path {
                    needsSecurityScope = true
                    securityScopedURL = bookmarkURL
                    if bookmarkURL.startAccessingSecurityScopedResource() {
                        print("✅ 保存时启用安全范围访问: \(saveDirectory.path)")
                    }
                }
            } catch {
                print("⚠️ 无法解析权限书签: \(error.localizedDescription)")
            }
        }
        
        do {
            // 检查保存目录是否存在
            if !FileManager.default.fileExists(atPath: saveDirectory.path) {
                print("❌ 保存目录不存在: \(saveDirectory.path)")
                if needsSecurityScope, let scopedURL = securityScopedURL {
                    scopedURL.stopAccessingSecurityScopedResource()
                }
                return
            }
            
            // 创建可编码的笔记数据
            let notesData = notes.map { note in
                NoteData(
                    id: note.id.uuidString,
                    title: note.title,
                    content: note.content,
                    createdAt: note.createdAt,
                    modifiedAt: note.modifiedAt
                )
            }
            
            let data = try JSONEncoder().encode(notesData)
            try data.write(to: fileURL)
            
            print("💾 笔记已保存: \(fileURL.path) (\(notes.count)条)")
            
            // 保存完成后停止安全范围访问
            if needsSecurityScope, let scopedURL = securityScopedURL {
                scopedURL.stopAccessingSecurityScopedResource()
            }
        } catch {
            print("❌ 保存笔记失败: \(error.localizedDescription)")
            print("❌ 目标路径: \(fileURL.path)")
            
            // 发生错误时也要停止安全范围访问
            if needsSecurityScope, let scopedURL = securityScopedURL {
                scopedURL.stopAccessingSecurityScopedResource()
            }
        }
    }
    
    // 加载单个容器的笔记
    func loadNotes(for appId: UUID) -> [Note] {
        let fileURL = noteFileURL(for: appId)
        
        do {
            let data = try Data(contentsOf: fileURL)
            let notesData = try JSONDecoder().decode([NoteData].self, from: data)
            
            let notes = notesData.compactMap { noteData -> Note? in
                guard let id = UUID(uuidString: noteData.id) else { return nil }
                
                return Note(
                    id: id,
                    title: noteData.title,
                    content: noteData.content,
                    createdAt: noteData.createdAt,
                    modifiedAt: noteData.modifiedAt
                )
            }
            
            print("📖 笔记已加载: \(fileURL.lastPathComponent) (\(notes.count)条)")
            return notes
        } catch {
            print("📝 没有找到笔记文件或加载失败: \(error.localizedDescription)")
            return []
        }
    }
    
    // 保存所有笔记（从全局应用模型）
    func saveAllNotes() {
        // 这个方法将通过通知系统触发
        NotificationCenter.default.post(name: .saveAllNotes, object: nil)
    }
    
    // 调试：打印当前保存路径
    func debugPrintSavePath() {
        print("📍 当前笔记保存路径: \(config.notesSaveLocation.path)")
        print("📁 目录是否存在: \(FileManager.default.fileExists(atPath: config.notesSaveLocation.path))")
    }
    
    // 删除笔记文件
    func deleteNotesFile(for appId: UUID) {
        let fileURL = noteFileURL(for: appId)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("🗑️ 笔记文件已删除: \(fileURL.lastPathComponent)")
        } catch {
            print("⚠️ 删除笔记文件失败: \(error.localizedDescription)")
        }
    }
    
    // 获取笔记统计信息
    func getNotesStatistics() -> (totalFiles: Int, totalNotes: Int, totalSize: String) {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: config.notesSaveLocation, includingPropertiesForKeys: [.fileSizeKey])
            let jsonFiles = files.filter { $0.pathExtension == "json" }
            
            var totalNotes = 0
            var totalSize: Int64 = 0
            
            for file in jsonFiles {
                // 计算文件大小
                if let size = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(size)
                }
                
                // 计算笔记数量
                do {
                    let data = try Data(contentsOf: file)
                    let notes = try JSONDecoder().decode([NoteData].self, from: data)
                    totalNotes += notes.count
                } catch {
                    // 忽略无法解析的文件
                }
            }
            
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useKB, .useMB]
            formatter.countStyle = .file
            
            return (
                totalFiles: jsonFiles.count,
                totalNotes: totalNotes,
                totalSize: formatter.string(fromByteCount: totalSize)
            )
        } catch {
            return (totalFiles: 0, totalNotes: 0, totalSize: "0 KB")
        }
    }
}

// 笔记数据结构（用于持久化）
private struct NoteData: Codable {
    let id: String
    let title: String
    let content: String
    let createdAt: Date
    let modifiedAt: Date
}

// 扩展通知名称
extension Notification.Name {
    static let saveAllNotes = Notification.Name("saveAllNotes")
    static let notesDidSave = Notification.Name("notesDidSave")
    static let resetToBlankPage = Notification.Name("resetToBlankPage")
    static let openSettings = Notification.Name("openSettings")
    static let manualSaveNotes = Notification.Name("manualSaveNotes")
}

// Note 结构定义（如果不存在）
struct Note: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var createdAt = Date()
    var modifiedAt = Date()
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
    
    // 从持久化数据初始化
    init(id: UUID, title: String, content: String, createdAt: Date, modifiedAt: Date) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}