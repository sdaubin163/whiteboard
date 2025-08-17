import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject private var config = AppConfig.shared
    @ObservedObject private var persistenceManager = NotePersistenceManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingFolderPicker = false
    @State private var showingResetAlert = false
    @State private var notesStats = (totalFiles: 0, totalNotes: 0, totalSize: "0 KB")
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("设置")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button("完成") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(ModernTheme.sidebarBackground)
            
            ScrollView {
                VStack(spacing: 24) {
                    // 笔记设置
                    SettingsSection(title: "笔记设置", icon: "note.text") {
                        VStack(spacing: 16) {
                            // 保存位置
                            SettingsRow(
                                title: "保存位置",
                                subtitle: config.notesSaveLocation.path,
                                icon: "folder"
                            ) {
                                VStack(spacing: 8) {
                                    Button("选择文件夹") {
                                        showingFolderPicker = true
                                    }
                                    .buttonStyle(.bordered)
                                    
                                    Button("授权访问") {
                                        requestFolderAccess()
                                    }
                                    .buttonStyle(.borderless)
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                }
                            }
                            
                            Divider()
                            
                            // 手动保存说明
                            SettingsRow(
                                title: "保存方式",
                                subtitle: "使用 Cmd+S 手动保存笔记",
                                icon: "keyboard"
                            ) {
                                Text("手动保存")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(ModernTheme.accentBlue.opacity(0.1))
                                    .foregroundColor(ModernTheme.accentBlue)
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    // 笔记统计
                    SettingsSection(title: "笔记统计", icon: "chart.bar") {
                        VStack(spacing: 16) {
                            SettingsRow(
                                title: "笔记文件数",
                                subtitle: "\(notesStats.totalFiles) 个文件",
                                icon: "doc"
                            ) {
                                EmptyView()
                            }
                            
                            Divider()
                            
                            SettingsRow(
                                title: "总笔记数",
                                subtitle: "\(notesStats.totalNotes) 条笔记",
                                icon: "note"
                            ) {
                                EmptyView()
                            }
                            
                            Divider()
                            
                            SettingsRow(
                                title: "占用空间",
                                subtitle: notesStats.totalSize,
                                icon: "externaldrive"
                            ) {
                                EmptyView()
                            }
                        }
                    }
                    
                    // 数据管理
                    SettingsSection(title: "数据管理", icon: "gear") {
                        VStack(spacing: 16) {
                            SettingsRow(
                                title: "立即保存所有笔记",
                                subtitle: "手动触发保存",
                                icon: "square.and.arrow.down.fill"
                            ) {
                                Button("保存") {
                                    persistenceManager.saveAllNotes()
                                    updateStats()
                                }
                                .buttonStyle(.bordered)
                            }
                            
                            Divider()
                            
                            SettingsRow(
                                title: "重置所有设置",
                                subtitle: "恢复默认配置",
                                icon: "arrow.clockwise"
                            ) {
                                Button("重置") {
                                    showingResetAlert = true
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(ModernTheme.contentBackground)
        .fileImporter(
            isPresented: $showingFolderPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            handleFolderSelection(result)
        }
        .alert("重置设置", isPresented: $showingResetAlert) {
            Button("取消", role: .cancel) { }
            Button("重置", role: .destructive) {
                resetSettings()
            }
        } message: {
            Text("这将重置所有设置到默认值，但不会删除已保存的笔记。")
        }
        .onAppear {
            updateStats()
        }
    }
    
    private func handleFolderSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let selectedURL = urls.first {
                // 开始安全范围访问
                if selectedURL.startAccessingSecurityScopedResource() {
                    print("✅ 获得文件夹访问权限: \(selectedURL.path)")
                    
                    // 保存书签以便后续访问（需要读写权限）
                    do {
                        let bookmarkData = try selectedURL.bookmarkData(
                            options: [.withSecurityScope],
                            includingResourceValuesForKeys: nil,
                            relativeTo: nil
                        )
                        
                        // 保存书签到用户偏好设置
                        UserDefaults.standard.set(bookmarkData, forKey: "NotesFolderBookmark")
                        
                        print("💾 文件夹访问权限已保存")
                    } catch {
                        print("⚠️ 保存文件夹权限失败: \(error.localizedDescription)")
                    }
                    
                    // 更新配置
                    config.updateNotesSaveLocation(selectedURL)
                    updateStats()
                    
                    // 停止访问（会自动由系统管理）
                    selectedURL.stopAccessingSecurityScopedResource()
                } else {
                    print("❌ 无法获得文件夹访问权限")
                }
            }
        case .failure(let error):
            print("❌ 选择文件夹失败: \(error.localizedDescription)")
        }
    }
    
    private func updateStats() {
        notesStats = persistenceManager.getNotesStatistics()
    }
    
    private func requestFolderAccess() {
        // 为当前目录重新请求权限
        let currentURL = config.notesSaveLocation
        
        // 开始安全范围访问
        if currentURL.startAccessingSecurityScopedResource() {
            print("✅ 手动获得文件夹访问权限: \(currentURL.path)")
            
            // 保存书签以便后续访问（需要读写权限）
            do {
                let bookmarkData = try currentURL.bookmarkData(
                    options: [.withSecurityScope],
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                
                // 保存书签到用户偏好设置
                UserDefaults.standard.set(bookmarkData, forKey: "NotesFolderBookmark")
                
                print("💾 文件夹访问权限已保存")
            } catch {
                print("⚠️ 保存文件夹权限失败: \(error.localizedDescription)")
            }
            
            // 停止访问（会自动由系统管理）
            currentURL.stopAccessingSecurityScopedResource()
        } else {
            print("❌ 无法获得文件夹访问权限，请尝试重新选择文件夹")
        }
    }
    
    private func resetSettings() {
        // 重置到默认设置
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let defaultNotesLocation = documentsPath.appendingPathComponent("WhiteboardApp").appendingPathComponent("Notes")
        
        config.updateNotesSaveLocation(defaultNotesLocation)
        
        updateStats()
    }
}

// 设置区域组件
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(ModernTheme.accentBlue)
                    .frame(width: 20)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(ModernTheme.primaryText)
            }
            
            VStack(spacing: 0) {
                content
            }
            .padding()
            .background(ModernTheme.sidebarBackground)
            .cornerRadius(12)
        }
    }
}

// 设置行组件
struct SettingsRow<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let content: Content
    
    init(title: String, subtitle: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(ModernTheme.secondaryText)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(ModernTheme.primaryText)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(ModernTheme.secondaryText)
            }
            
            Spacer()
            
            content
        }
    }
}

#Preview {
    SettingsView()
}