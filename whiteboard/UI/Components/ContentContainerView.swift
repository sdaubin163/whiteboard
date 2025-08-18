import SwiftUI

// 缓存容器项，包含视图和时间戳
private struct CachedContainer {
    let view: AnyView
    let createdAt: Date
    var lastAccessedAt: Date
    
    init(view: AnyView) {
        self.view = view
        self.createdAt = Date()
        self.lastAccessedAt = Date()
    }
    
    mutating func updateLastAccessed() {
        self.lastAccessedAt = Date()
    }
}

struct ContentContainerView: View {
    @ObservedObject var appModel: AppModel
    @State private var containerViewCache: [UUID: CachedContainer] = [:]
    @State private var cleanupTimer: Timer?
    private let maxCacheSize = 5 // 最多缓存5个容器
    private let maxCacheAge: TimeInterval = 18 * 60 * 60 // 18小时
    // 调试模式：设置为更短的时间便于测试（10分钟）
    private let debugMode = false
    private var effectiveCacheAge: TimeInterval {
        return debugMode ? 600 : maxCacheAge // 调试模式下10分钟过期
    }
    
    var body: some View {
        ZStack {
            // 显示所有已缓存的容器
            ForEach(Array(containerViewCache.keys), id: \.self) { appId in
                if let cachedContainer = containerViewCache[appId] {
                    let isActive = appModel.selectedApp?.id == appId
                    
                    cachedContainer.view
                        // 将非活跃视图移到屏幕外而不改变其尺寸
                        .offset(x: isActive ? 0 : -10000, y: isActive ? 0 : -10000)
                        .opacity(isActive ? 1 : 0) // 保留透明度动画以实现平滑过渡
                        .allowsHitTesting(isActive)
                        .animation(.easeInOut(duration: 0.01), value: appModel.selectedApp?.id)
                }
            }
            
            // 占位内容（当没有选中应用时显示）
            if appModel.selectedApp == nil {
                EmptyStateView()
                    .transition(.opacity)
            }
        }
        .background(ContentPanel())
        .clipped()
        .onChange(of: appModel.selectedApp?.id) { _, newAppId in
            if let selectedApp = appModel.selectedApp {
                if containerViewCache[selectedApp.id] == nil {
                    // 只有在缓存中不存在时才创建新容器
                    createAndCacheContainer(for: selectedApp)
                } else {
                    // 更新最后访问时间
                    updateLastAccessTime(for: selectedApp.id)
                }
            }
        }
        .onAppear {
            startCleanupTimer()
        }
        .onDisappear {
            stopCleanupTimer()
        }
    }
    
    private func createAndCacheContainer(for app: AppItem) {
        print("🆕 创建并缓存容器视图: \(app.name)")
        
        // 首先清理过期的容器
        cleanupExpiredContainers()
        
        // 如果缓存仍然已满，移除最老的容器（简单的LRU策略）
        if containerViewCache.count >= maxCacheSize {
            removeOldestContainer()
        }
        
        let containerView = createIsolatedContentView(for: app)
        let cachedContainer = CachedContainer(view: AnyView(containerView))
        containerViewCache[app.id] = cachedContainer
        
        print("📦 缓存状态: \(containerViewCache.count)/\(maxCacheSize) 个容器")
    }
    
    private func updateLastAccessTime(for appId: UUID) {
        containerViewCache[appId]?.updateLastAccessed()
    }
    
    private func removeOldestContainer() {
        guard !containerViewCache.isEmpty else { return }
        
        // 找到最老的容器（基于最后访问时间）
        let oldestEntry = containerViewCache.min { first, second in
            first.value.lastAccessedAt < second.value.lastAccessedAt
        }
        
        if let oldestKey = oldestEntry?.key {
            print("🗑️ 缓存已满，移除最老的容器: \(oldestKey)")
            containerViewCache.removeValue(forKey: oldestKey)
        }
    }
    
    private func cleanupExpiredContainers() {
        let now = Date()
        var removedCount = 0
        
        containerViewCache = containerViewCache.filter { _, cachedContainer in
            let age = now.timeIntervalSince(cachedContainer.createdAt)
            if age > effectiveCacheAge {
                removedCount += 1
                return false // 移除过期容器
            }
            return true // 保留未过期容器
        }
        
        if removedCount > 0 {
            print("🧹 清理了 \(removedCount) 个过期容器（超过18小时）")
        }
    }
    
    private func startCleanupTimer() {
        // 每小时检查一次过期容器，调试模式下每分钟检查一次
        let checkInterval: TimeInterval = debugMode ? 60 : 3600
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { _ in
            self.cleanupExpiredContainers()
        }
        let checkFrequency = debugMode ? "每分钟" : "每小时"
        let expireTime = debugMode ? "10分钟" : "18小时"
        print("⏰ 启动容器清理定时器（\(checkFrequency)检查一次，\(expireTime)过期）")
    }
    
    private func stopCleanupTimer() {
        cleanupTimer?.invalidate()
        cleanupTimer = nil
        print("⏰ 停止容器清理定时器")
    }
    
    // 手动清理缓存的方法
    func clearCache() {
        print("🧹 手动清理所有容器缓存")
        containerViewCache.removeAll()
    }
    
    // 手动清理过期容器的方法
    func clearExpiredContainers() {
        print("🧹 手动清理过期容器")
        cleanupExpiredContainers()
    }
    
    // 获取缓存统计信息
    func getCacheStatistics() -> (total: Int, expired: Int) {
        let now = Date()
        let expiredCount = containerViewCache.values.filter { cachedContainer in
            now.timeIntervalSince(cachedContainer.createdAt) > effectiveCacheAge
        }.count
        
        return (total: containerViewCache.count, expired: expiredCount)
    }
    
    // 开发者调试：获取详细缓存信息
    func getDetailedCacheInfo() -> [(appId: UUID, age: String, lastAccess: String)] {
        let now = Date()
        return containerViewCache.map { appId, cachedContainer in
            let age = now.timeIntervalSince(cachedContainer.createdAt)
            let lastAccessAge = now.timeIntervalSince(cachedContainer.lastAccessedAt)
            
            return (
                appId: appId,
                age: formatTimeInterval(age),
                lastAccess: formatTimeInterval(lastAccessAge)
            )
        }.sorted { $0.age > $1.age }
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    @ViewBuilder
    private func createIsolatedContentView(for app: AppItem) -> some View {
        // 每个应用类型使用完全独立的视图层次结构
        switch app.contentType {
        case .webView:
            IsolatedWebViewContainer(app: app, appModel: appModel)
                .id("webview-\(app.id)") // 每个WebView实例独立
        case .textEditor:
            IsolatedTextEditorContainer(app: app, appModel: appModel)
                .id("texteditor-\(app.id)") // 每个文本编辑器实例独立
        case .notes:
            IsolatedNotesContainer(app: app, appModel: appModel)
                .id("notes-\(app.id)") // 每个笔记容器实例独立
        }
    }
}

// 空状态视图
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 64, weight: .ultraLight))
                .foregroundColor(ModernTheme.secondaryText)
            
            VStack(spacing: 8) {
                Text("选择一个应用开始使用")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(ModernTheme.primaryText)
                
                Text("从左侧选择应用访问网页、编辑文档或使用工具")
                    .font(.body)
                    .foregroundColor(ModernTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ModernTheme.contentBackground)
    }
}

// 隔离的 WebView 容器
struct IsolatedWebViewContainer: View {
    let app: AppItem
    @ObservedObject var appModel: AppModel
    
    var body: some View {
        Group {
            if let containerState = appModel.containers[app.id] {
                WebViewContainer(app: app, containerState: containerState)
            } else {
                // 容器未初始化的占位视图
                ContainerPreparationView(app: app)
                    .onAppear {
                        print("🔄 IsolatedWebViewContainer onAppear for \(app.name)")
                        // 确保容器状态已创建
                        _ = appModel.getContainerState(for: app.id)
                    }
            }
        }
        .background(ModernTheme.contentBackground)
        .cornerRadius(0)
    }
}

// 隔离的文本编辑器容器
struct IsolatedTextEditorContainer: View {
    let app: AppItem
    @ObservedObject var appModel: AppModel
    
    var body: some View {
        Group {
            if let containerState = appModel.containers[app.id] {
                TextEditorContainer(containerState: containerState)
            } else {
                ContainerPreparationView(app: app)
                    .onAppear {
                        _ = appModel.getContainerState(for: app.id)
                    }
            }
        }
        .background(ModernTheme.contentBackground)
        .cornerRadius(0)
    }
}

// 隔离的笔记容器
struct IsolatedNotesContainer: View {
    let app: AppItem
    @ObservedObject var appModel: AppModel
    
    var body: some View {
        Group {
            if let containerState = appModel.containers[app.id] {
                NotesContainer(containerState: containerState)
            } else {
                ContainerPreparationView(app: app)
                    .onAppear {
                        _ = appModel.getContainerState(for: app.id)
                    }
            }
        }
        .background(ModernTheme.contentBackground)
        .cornerRadius(0)
    }
}

// 容器准备视图
struct ContainerPreparationView: View {
    let app: AppItem
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: app.icon)
                .font(.system(size: 48))
                .foregroundColor(ModernTheme.secondaryText)
            
            Text("正在准备 \(app.name)")
                .font(.title2)
                .foregroundColor(ModernTheme.primaryText)
            
            ProgressView()
                .scaleEffect(0.8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ModernTheme.contentBackground)
    }
}