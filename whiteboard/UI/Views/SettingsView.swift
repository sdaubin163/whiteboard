import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject private var config = AppConfig.shared
    @ObservedObject private var persistenceManager = NotePersistenceManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingFolderPicker = false
    @State private var showingResetAlert = false
    @State private var notesStats = (totalFiles: 0, totalNotes: 0, totalSize: "0 KB")
    @State private var refreshView = false // 用于强制刷新界面
    
    // 代理设置状态
    @State private var proxyEnabled = false
    @State private var proxyType = "HTTP"
    @State private var proxyHost = ""
    @State private var proxyPort = 8080
    @State private var proxyUsername = ""
    @State private var proxyPassword = ""
    @State private var proxyAuthRequired = false
    @State private var isTestingProxy = false
    @State private var proxyTestResult = ""
    
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
                    // 外观设置
                    SettingsSection(title: "外观设置", icon: "paintpalette") {
                        VStack(spacing: 16) {
                            // 主题模式选择
                            SettingsRow(
                                title: "主题模式",
                                subtitle: "选择应用的外观主题",
                                icon: "circle.lefthalf.filled"
                            ) {
                                Picker("主题模式", selection: Binding(
                                    get: { config.themeMode },
                                    set: { config.updateThemeMode($0) }
                                )) {
                                    ForEach(ModernTheme.ThemeMode.allCases, id: \.rawValue) { mode in
                                        Text(mode.rawValue)
                                            .tag(mode.rawValue)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 180)
                            }
                        }
                    }
                    
                    // 网络设置
                    SettingsSection(title: "网络设置", icon: "network") {
                        VStack(spacing: 16) {
                            // 代理启用开关
                            SettingsRow(
                                title: "启用代理",
                                subtitle: proxyEnabled ? "代理已启用" : "代理已禁用",
                                icon: "globe"
                            ) {
                                Toggle("", isOn: $proxyEnabled)
                                    .onChange(of: proxyEnabled) { _ in
                                        saveProxySettings()
                                    }
                            }
                            
                            if proxyEnabled {
                                Divider()
                                
                                // 代理类型选择
                                SettingsRow(
                                    title: "代理类型",
                                    subtitle: proxyType,
                                    icon: "arrow.triangle.swap"
                                ) {
                                    Picker("代理类型", selection: $proxyType) {
                                        Text("HTTP").tag("HTTP")
                                        Text("HTTPS").tag("HTTPS")
                                        Text("SOCKS5").tag("SOCKS5")
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 200)
                                    .onChange(of: proxyType) { _ in
                                        saveProxySettings()
                                    }
                                }
                                
                                Divider()
                                
                                // 代理服务器地址
                                SettingsRow(
                                    title: "服务器地址",
                                    subtitle: proxyHost.isEmpty ? "请输入代理服务器地址" : proxyHost,
                                    icon: "server.rack"
                                ) {
                                    TextField("例如: 127.0.0.1", text: $proxyHost)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 150)
                                        .onChange(of: proxyHost) { _ in
                                            saveProxySettings()
                                        }
                                }
                                
                                Divider()
                                
                                // 代理端口
                                SettingsRow(
                                    title: "端口",
                                    subtitle: "\(proxyPort)",
                                    icon: "number"
                                ) {
                                    TextField("端口", value: $proxyPort, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 80)
                                        .onChange(of: proxyPort) { _ in
                                            saveProxySettings()
                                        }
                                }
                                
                                Divider()
                                
                                // 认证设置
                                SettingsRow(
                                    title: "需要认证",
                                    subtitle: proxyAuthRequired ? "启用用户名密码认证" : "无需认证",
                                    icon: "key"
                                ) {
                                    Toggle("", isOn: $proxyAuthRequired)
                                        .onChange(of: proxyAuthRequired) { _ in
                                            saveProxySettings()
                                        }
                                }
                                
                                if proxyAuthRequired {
                                    Divider()
                                    
                                    // 用户名
                                    SettingsRow(
                                        title: "用户名",
                                        subtitle: proxyUsername.isEmpty ? "请输入用户名" : proxyUsername,
                                        icon: "person"
                                    ) {
                                        TextField("用户名", text: $proxyUsername)
                                            .textFieldStyle(.roundedBorder)
                                            .frame(width: 120)
                                            .onChange(of: proxyUsername) { _ in
                                                saveProxySettings()
                                            }
                                    }
                                    
                                    Divider()
                                    
                                    // 密码
                                    SettingsRow(
                                        title: "密码",
                                        subtitle: proxyPassword.isEmpty ? "请输入密码" : "••••••••",
                                        icon: "lock"
                                    ) {
                                        SecureField("密码", text: $proxyPassword)
                                            .textFieldStyle(.roundedBorder)
                                            .frame(width: 120)
                                            .onChange(of: proxyPassword) { _ in
                                                saveProxySettings()
                                            }
                                    }
                                }
                                
                                Divider()
                                
                                // 测试连接
                                SettingsRow(
                                    title: "测试连接",
                                    subtitle: proxyTestResult.isEmpty ? "点击测试代理连接" : proxyTestResult,
                                    icon: "checkmark.circle"
                                ) {
                                    Button(isTestingProxy ? "测试中..." : "测试") {
                                        testProxyConnection()
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(isTestingProxy || proxyHost.isEmpty)
                                }
                            }
                        }
                    }
                    
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
                            
                            Divider()
                            
                            // 自动保存间隔设置
                            SettingsRow(
                                title: "自动保存间隔",
                                subtitle: "\(formatInterval(config.autoSaveInterval)) - 内容变更时自动保存",
                                icon: "timer"
                            ) {
                                VStack(spacing: 8) {
                                    Slider(
                                        value: Binding(
                                            get: { config.autoSaveInterval },
                                            set: { config.updateAutoSaveInterval($0) }
                                        ),
                                        in: 5...300,
                                        step: 5
                                    ) {
                                        Text("自动保存间隔")
                                    }
                                    .frame(width: 120)
                                    
                                    Text("\(formatInterval(config.autoSaveInterval))")
                                        .font(.caption)
                                        .foregroundColor(ModernTheme.secondaryText)
                                }
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
            loadProxySettings()
            
            // 监听主题变更通知
            NotificationCenter.default.addObserver(
                forName: .themeChanged,
                object: nil,
                queue: .main
            ) { _ in
                // 强制刷新界面以应用新主题
                refreshView.toggle()
            }
        }
        .id(refreshView) // 当 refreshView 变化时强制重建视图
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
    
    // 格式化时间间隔显示
    private func formatInterval(_ interval: TimeInterval) -> String {
        let seconds = Int(interval)
        if seconds < 60 {
            return "\(seconds)秒"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            if remainingSeconds == 0 {
                return "\(minutes)分钟"
            } else {
                return "\(minutes)分\(remainingSeconds)秒"
            }
        }
    }
    
    // 加载代理设置
    private func loadProxySettings() {
        proxyEnabled = config.proxyEnabled
        proxyType = config.proxyType
        proxyHost = config.proxyHost
        proxyPort = config.proxyPort
        proxyUsername = config.proxyUsername
        proxyPassword = config.proxyPassword
        proxyAuthRequired = config.proxyAuthRequired
    }
    
    // 保存代理设置
    private func saveProxySettings() {
        config.updateProxySettings(
            enabled: proxyEnabled,
            type: proxyType,
            host: proxyHost,
            port: proxyPort,
            username: proxyUsername,
            password: proxyPassword,
            authRequired: proxyAuthRequired
        )
    }
    
    // 测试代理连接
    private func testProxyConnection() {
        isTestingProxy = true
        proxyTestResult = "正在测试..."
        
        ProxyManager.shared.testProxyConnection { success, message in
            isTestingProxy = false
            proxyTestResult = message
            
            // 3秒后清除测试结果
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                proxyTestResult = ""
            }
        }
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