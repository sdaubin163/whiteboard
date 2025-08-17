import Foundation
import SwiftUI

// AppModel 的持久化扩展
extension AppModel {
    
    // 选择应用并加载相关数据（覆盖原有方法）
    func selectAppWithPersistence(_ app: AppItem) {
        print("🎯 用户选择应用: \(app.name)")
        
        // 隐藏之前选中的容器
        if let previousApp = selectedApp {
            containers[previousApp.id]?.isVisible = false
            print("⏸️ 隐藏容器: \(previousApp.name)")
        }
        
        selectedApp = app
        
        // 懒加载：只在用户首次点击时创建容器
        if containers[app.id] == nil {
            print("🆕 首次访问，创建容器: \(app.name)")
            let containerState = AppContainerState(appId: app.id, contentType: app.contentType)
            containerState.isVisible = true
            containers[app.id] = containerState
            
            // 根据内容类型进行特殊初始化
            switch app.contentType {
            case .webView:
                if let urlString = app.url, let url = URL(string: urlString) {
                    containerState.webViewURL = url
                    print("🌐 设置 WebView URL: \(url.absoluteString)")
                }
            case .notes:
                loadNotesForContainer(app.id)
            case .textEditor:
                break
            }
        } else {
            print("♻️ 复用已存在的容器: \(app.name)")
            // 显示已存在的容器并更新访问时间
            containers[app.id]?.isVisible = true
            containers[app.id]?.lastAccessTime = Date()
        }
    }
    
    // 设置笔记持久化
    func setupNotePersistence() {
        // 监听保存所有笔记的通知
        NotificationCenter.default.addObserver(
            forName: .saveAllNotes,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.saveAllNotesToDisk()
        }
        
        print("📚 笔记持久化系统已启用")
    }
    
    // 预加载笔记数据
    func preloadNotesData() {
        // 找到笔记应用
        guard let notesApp = apps.first(where: { $0.contentType == .notes }) else {
            print("⚠️ 未找到笔记应用")
            return
        }
        
        // 如果笔记容器还不存在，创建它
        if containers[notesApp.id] == nil {
            print("🆕 创建笔记容器用于预加载")
            let containerState = AppContainerState(appId: notesApp.id, contentType: notesApp.contentType)
            containers[notesApp.id] = containerState
        }
        
        // 加载笔记数据
        let loadedNotes = NotePersistenceManager.shared.loadNotes(for: notesApp.id)
        containers[notesApp.id]?.notes = loadedNotes
        
        print("📖 应用启动时预加载了 \(loadedNotes.count) 条笔记")
    }
    
    // 为特定容器加载笔记
    func loadNotesForContainer(_ appId: UUID) {
        guard let containerState = containers[appId],
              containerState.contentType == .notes else { return }
        
        let loadedNotes = NotePersistenceManager.shared.loadNotes(for: appId)
        containerState.notes = loadedNotes
        
        print("📖 为容器加载了 \(loadedNotes.count) 条笔记")
    }
    
    // 保存特定容器的笔记
    func saveNotesForContainer(_ appId: UUID) {
        guard let containerState = containers[appId],
              containerState.contentType == .notes else { return }
        
        NotePersistenceManager.shared.saveNotes(for: appId, notes: containerState.notes)
    }
    
    // 保存所有笔记容器的笔记
    private func saveAllNotesToDisk() {
        let notesContainers = containers.filter { $0.value.contentType == .notes }
        
        for (appId, containerState) in notesContainers {
            NotePersistenceManager.shared.saveNotes(for: appId, notes: containerState.notes)
        }
        
        print("💾 已保存所有笔记容器的数据")
        
        // 发送保存完成通知
        NotificationCenter.default.post(name: .notesDidSave, object: nil)
    }
    
    // 当笔记内容发生变化时调用（用于自动保存）
    func onNotesChanged(for appId: UUID) {
        // 延迟保存，避免频繁写入
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.saveNotesForContainer(appId)
        }
    }
}

// AppContainerState 的笔记持久化扩展
extension AppContainerState {
    
    // 初始化时加载笔记
    func loadNotesIfNeeded() {
        guard contentType == .notes && notes.isEmpty else { return }
        
        let loadedNotes = NotePersistenceManager.shared.loadNotes(for: appId)
        if !loadedNotes.isEmpty {
            notes = loadedNotes
            print("📖 容器 \(appId) 已加载 \(loadedNotes.count) 条笔记")
        }
    }
    
    // 添加笔记（不自动保存）
    func addNote(_ note: Note) {
        notes.append(note)
    }
    
    // 更新笔记（不自动保存）
    func updateNote(at index: Int, title: String? = nil, content: String? = nil) {
        guard index < notes.count else { return }
        
        if let title = title {
            notes[index].title = title
        }
        if let content = content {
            notes[index].content = content
        }
        notes[index].modifiedAt = Date()
    }
    
    // 删除笔记（不自动保存）
    func removeNote(at index: Int) {
        guard index < notes.count else { return }
        notes.remove(at: index)
    }
    
    // 删除指定笔记（不自动保存）
    func removeNote(withId id: UUID) {
        notes.removeAll { $0.id == id }
    }
    
    // 手动保存笔记
    func manualSaveNotes() {
        guard contentType == .notes else { return }
        NotePersistenceManager.shared.saveNotes(for: self.appId, notes: self.notes)
    }
}