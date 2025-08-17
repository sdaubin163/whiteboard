import SwiftUI
import UniformTypeIdentifiers

struct AppContainerView: View {
    let app: AppItem
    @ObservedObject var containerState: AppContainerState
    
    var body: some View {
        Group {
            switch app.contentType {
            case .webView:
                WebViewContainer(app: app, containerState: containerState)
            case .textEditor:
                TextEditorContainer(containerState: containerState)
            case .notes:
                NotesContainer(containerState: containerState)
            }
        }
        .onAppear {
            setupContainer()
        }
    }
    
    private func setupContainer() {
        switch app.contentType {
        case .webView:
            if let urlString = app.url, let url = URL(string: urlString) {
                containerState.webViewURL = url
            }
        case .textEditor, .notes:
            break
        }
    }
}

// WebView 容器
struct WebViewContainer: View {
    let app: AppItem
    @ObservedObject var containerState: AppContainerState
    @State private var showLoadingOverlay = true
    
    var body: some View {
        ZStack {
            if let url = containerState.webViewURL {
                PersistentWebView(
                    url: url, 
                    isVisible: containerState.isVisible,
                    onLoadingStateChange: { isLoading in
                        containerState.isWebViewLoading = isLoading
                        
                        // 如果开始加载，清除之前的错误
                        if isLoading {
                            containerState.webViewError = nil
                        }
                        
                        // 控制加载覆盖层的显示
                        if !isLoading && containerState.webViewError == nil {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showLoadingOverlay = false
                            }
                        }
                    },
                    onFirstContentLoad: {
                        // 当页面首次有内容时隐藏加载覆盖层
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showLoadingOverlay = false
                        }
                    },
                    onLoadError: { error in
                        containerState.webViewError = error
                        containerState.isWebViewLoading = false
                        
                        // 显示错误覆盖层
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showLoadingOverlay = true
                        }
                    }
                )
                .id("webview_\(app.id)")
                
                // 加载/错误覆盖层
                if showLoadingOverlay {
                    if containerState.webViewError != nil {
                        WebViewErrorOverlay(app: app, containerState: containerState)
                            .transition(.opacity)
                    } else {
                        WebViewLoadingOverlay(app: app, containerState: containerState)
                            .transition(.opacity)
                    }
                }
            } else {
                // 初始化状态
                WebViewPreparationView(app: app, containerState: containerState)
            }
        }
    }
}

// WebView 加载覆盖层
struct WebViewLoadingOverlay: View {
    let app: AppItem
    @ObservedObject var containerState: AppContainerState
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.white.opacity(0.95)
            
            VStack(spacing: 24) {
                // 应用图标
                Image(systemName: app.icon)
                    .font(.system(size: 56))
                    .foregroundColor(ModernTheme.accentBlue)
                    .scaleEffect(containerState.isWebViewLoading ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: containerState.isWebViewLoading)
                
                VStack(spacing: 12) {
                    Text("正在加载 \(app.name)")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(ModernTheme.primaryText)
                    
                    Text("请稍候...")
                        .font(.body)
                        .foregroundColor(ModernTheme.secondaryText)
                    
                    // 加载进度指示器
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(ModernTheme.accentBlue)
                                .frame(width: 8, height: 8)
                                .scaleEffect(containerState.isWebViewLoading ? 1.0 : 0.5)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: containerState.isWebViewLoading
                                )
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// WebView 错误覆盖层
struct WebViewErrorOverlay: View {
    let app: AppItem
    @ObservedObject var containerState: AppContainerState
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.red.opacity(0.05)
            
            VStack(spacing: 24) {
                // 错误图标
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 56))
                    .foregroundColor(.red)
                
                VStack(spacing: 12) {
                    Text("加载失败")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(ModernTheme.primaryText)
                    
                    Text("无法加载 \(app.name)")
                        .font(.body)
                        .foregroundColor(ModernTheme.secondaryText)
                    
                    if let error = containerState.webViewError {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(ModernTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                // 重试按钮
                HStack(spacing: 16) {
                    Button("重试") {
                        retryLoading()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button("检查网络") {
                        openNetworkSettings()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func retryLoading() {
        containerState.webViewError = nil
        containerState.isWebViewLoading = true
        
        // 触发重新加载
        if let url = containerState.webViewURL {
            print("🔄 用户手动重试加载: \(url.absoluteString)")
        }
    }
    
    private func openNetworkSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Network-Settings.extension") {
            NSWorkspace.shared.open(url)
        } else {
            // 备用方案：打开系统偏好设置
            if let url = URL(string: "x-apple.systempreferences:") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}

// WebView 准备状态视图
struct WebViewPreparationView: View {
    let app: AppItem
    @ObservedObject var containerState: AppContainerState
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: app.icon)
                .font(.system(size: 48))
                .foregroundColor(ModernTheme.secondaryText)
            
            Text("正在准备 \(app.name)")
                .font(.title2)
                .foregroundColor(ModernTheme.primaryText)
            
            if containerState.isWebViewLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ModernTheme.contentBackground)
    }
}

// 文本编辑器容器
struct TextEditorContainer: View {
    @ObservedObject var containerState: AppContainerState
    @State private var showingSaveAlert = false
    @State private var showingFileDialog = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 工具栏
            HStack {
                TextField("文档标题", text: $containerState.textEditorTitle)
                    .textFieldStyle(.plain)
                    .font(.headline)
                    .foregroundColor(ModernTheme.primaryText)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button("新建") {
                        newDocument()
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.small)
                    
                    Button("打开") {
                        showingFileDialog = true
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.small)
                    
                    Button("保存") {
                        saveDocument()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            .padding()
            .background(ModernTheme.sidebarBackground)
            
            // 分隔线
            Rectangle()
                .fill(ModernTheme.separatorColor)
                .frame(height: 1)
            
            // 编辑器
            TextEditor(text: $containerState.textContent)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(ModernTheme.primaryText)
                .padding()
                .scrollContentBackground(.hidden)
                .background(ModernTheme.contentBackground)
                .onAppear {
                    // 设置文本编辑器的外观
                    if let textView = findTextView() {
                        textView.isAutomaticQuoteSubstitutionEnabled = false
                        textView.isAutomaticDashSubstitutionEnabled = false
                        textView.isAutomaticTextReplacementEnabled = false
                    }
                }
        }
        .alert("文档已保存", isPresented: $showingSaveAlert) {
            Button("好的") { }
        }
        .fileImporter(isPresented: $showingFileDialog, allowedContentTypes: [.text, .plainText]) { result in
            loadDocument(result: result)
        }
    }
    
    private func newDocument() {
        containerState.textContent = ""
        containerState.textEditorTitle = "未命名文档"
    }
    
    private func saveDocument() {
        // 简单的保存提示，实际项目中可以实现文件保存
        showingSaveAlert = true
    }
    
    private func loadDocument(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                containerState.textContent = content
                containerState.textEditorTitle = url.lastPathComponent
            } catch {
                print("加载文件失败: \(error)")
            }
        case .failure(let error):
            print("选择文件失败: \(error)")
        }
    }
    
    private func findTextView() -> NSTextView? {
        // 辅助函数找到 TextEditor 的 NSTextView
        return nil // 简化实现
    }
}

// 笔记容器
struct NotesContainer: View {
    @ObservedObject var containerState: AppContainerState
    @State private var selectedNote: Note?
    @State private var showingNewNote = false
    @State private var editingNoteTitle = ""
    @State private var editingNoteContent = ""
    
    var body: some View {
        HStack(spacing: 0) {
            // 笔记列表
            VStack(spacing: 0) {
                HStack {
                    Text("笔记")
                        .font(.headline)
                        .foregroundColor(ModernTheme.primaryText)
                    
                    Spacer()
                    
                    Button(action: { showingNewNote = true }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                .background(ModernTheme.sidebarBackground)
                
                List(containerState.notes, id: \.id) { note in
                    Button(action: {
                        selectNote(note)
                    }) {
                        VStack(alignment: .leading, spacing: 6) {
                            // 笔记标题
                            Text(note.title.isEmpty ? "未命名笔记" : note.title)
                                .font(.system(.subheadline, weight: .medium))
                                .foregroundColor(ModernTheme.primaryText)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            // 笔记预览内容 - 显示前两行非空内容
                            let previewText = cleanPreviewText(note.content)
                            Text(previewText)
                                .font(.caption)
                                .foregroundColor(previewText == "暂无内容" ? 
                                               ModernTheme.secondaryText.opacity(0.6) : 
                                               ModernTheme.secondaryText)
                                .lineLimit(2)
                                .truncationMode(.tail)
                                .multilineTextAlignment(.leading)
                                .italic(previewText == "暂无内容")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                    }
                    .buttonStyle(PlainButtonStyle()) // 避免默认按钮样式
                    .background(selectedNote?.id == note.id ? ModernTheme.selectedBackground : Color.clear)
                    .cornerRadius(8)
                    .listRowBackground(ModernTheme.sidebarBackground) // 设置列表行背景
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden) // 隐藏默认背景
                .background(ModernTheme.sidebarBackground) // 设置列表背景
                .padding(.horizontal, 8)
            }
            .frame(width: 280) // 稍微增加宽度以容纳新的布局
            .background(ModernTheme.sidebarBackground)
            
            // 分隔线
            Rectangle()
                .fill(ModernTheme.separatorColor)
                .frame(width: 1)
            
            // 笔记编辑器
            if selectedNote != nil {
                VStack(spacing: 0) {
                    // 编辑器工具栏
                    HStack {
                        TextField("笔记标题", text: $editingNoteTitle)
                            .textFieldStyle(.plain)
                            .font(.headline)
                            .foregroundColor(ModernTheme.primaryText)
                            .onSubmit {
                                updateNoteTitle()
                            }
                        
                        Spacer()
                        
                        // 变更状态指示器
                        if containerState.hasUnsavedChanges {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 6, height: 6)
                                Text("未保存")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        } else {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                Text("已保存")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Button("删除") {
                            deleteCurrentNote()
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.red)
                        .controlSize(.small)
                    }
                    .padding()
                    .background(ModernTheme.sidebarBackground)
                    
                    Rectangle()
                        .fill(ModernTheme.separatorColor)
                        .frame(height: 1)
                    
                    TextEditor(text: $editingNoteContent)
                        .font(.body)
                        .foregroundColor(ModernTheme.primaryText)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scrollContentBackground(.hidden)
                        .background(ModernTheme.contentBackground)
                        .textSelection(.enabled) // 确保文本选择功能启用
                        .onChange(of: editingNoteContent) {
                            updateNoteContent()
                        }
                }
                .background(ModernTheme.contentBackground)
                .onReceive(NotificationCenter.default.publisher(for: .manualSaveNotes)) { _ in
                    manualSaveCurrentNote()
                }
            } else {
                VStack {
                    Image(systemName: "note.text")
                        .font(.system(size: 48))
                        .foregroundColor(ModernTheme.secondaryText)
                    Text("选择一个笔记开始编辑")
                        .foregroundColor(ModernTheme.secondaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(ModernTheme.contentBackground)
            }
        }
        .sheet(isPresented: $showingNewNote) {
            NewNoteView { title, content in
                addNewNote(title: title, content: content)
            }
        }
    }
    
    // 获取笔记的前两行非空内容
    private func cleanPreviewText(_ text: String) -> String {
        // 按行分割文本
        let lines = text.components(separatedBy: .newlines)
        
        // 找到前两行非空内容
        var nonEmptyLines: [String] = []
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedLine.isEmpty {
                nonEmptyLines.append(trimmedLine)
                if nonEmptyLines.count >= 2 {
                    break
                }
            }
        }
        
        // 如果没有找到非空行，返回提示
        if nonEmptyLines.isEmpty {
            return "暂无内容"
        }
        
        // 将找到的行用换行符连接，保持原有的行结构
        return nonEmptyLines.joined(separator: "\n")
    }
    
    private func selectNote(_ note: Note) {
        selectedNote = note
        editingNoteTitle = note.title
        editingNoteContent = note.content
    }
    
    private func updateNoteTitle() {
        if let index = containerState.notes.firstIndex(where: { $0.id == selectedNote?.id }) {
            containerState.updateNote(at: index, title: editingNoteTitle)
        }
    }
    
    private func updateNoteContent() {
        if let index = containerState.notes.firstIndex(where: { $0.id == selectedNote?.id }) {
            containerState.updateNote(at: index, content: editingNoteContent)
        }
    }
    
    private func deleteCurrentNote() {
        if let note = selectedNote {
            containerState.removeNote(withId: note.id)
            selectedNote = nil
            editingNoteTitle = ""
            editingNoteContent = ""
            
            // 删除后手动保存
            containerState.manualSaveNotes()
        }
    }
    
    private func manualSaveCurrentNote() {
        if selectedNote != nil {
            print("💾 手动保存笔记 (Cmd+S)")
            updateNoteTitle()
            updateNoteContent()
            
            // 手动保存到磁盘
            containerState.manualSaveNotes()
            
            // 显示保存提示
            print("✅ 笔记已保存")
        }
    }
    
    private func addNewNote(title: String, content: String) {
        let newNote = Note(title: title, content: content)
        containerState.addNote(newNote)
        selectNote(newNote)
        
        // 添加新笔记后手动保存
        containerState.manualSaveNotes()
    }
}

// 新建笔记视图
struct NewNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    let onSave: (String, String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("新建笔记")
                    .font(.headline)
                
                Spacer()
                
                Button("取消") {
                    dismiss()
                }
                .buttonStyle(.borderless)
                
                Button("保存") {
                    saveNote()
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("标题")
                    .font(.headline)
                TextField("请输入笔记标题", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        // 按回车键时触发保存
                        if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            saveNote()
                        }
                    }
                    .focused($isTitleFocused)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(width: 400, height: 200)
        .background(ModernTheme.contentBackground)
        .onAppear {
            // 视图出现时自动聚焦到标题输入框
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTitleFocused = true
            }
        }
    }
    
    @FocusState private var isTitleFocused: Bool
    
    private func saveNote() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = trimmedTitle.isEmpty ? "未命名笔记" : trimmedTitle
        onSave(finalTitle, "") // 内容为空字符串
        dismiss()
    }
}