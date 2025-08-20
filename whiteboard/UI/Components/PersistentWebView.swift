import SwiftUI
import WebKit
import AppKit

// 自定义 WebView 类，支持右键菜单
class CustomWKWebView: WKWebView {
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        // 移除所有现有的跟踪区域
        for trackingArea in trackingAreas {
            removeTrackingArea(trackingArea)
        }
        
        // 创建新的跟踪区域，限制在 WebView 范围内
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeInKeyWindow, .mouseEnteredAndExited, .mouseMoved],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        // 当鼠标离开 WebView 时，重置光标为系统默认
        NSCursor.arrow.set()
    }
    override func rightMouseDown(with event: NSEvent) {
        // 创建右键菜单
        let menu = NSMenu()
        
        // 刷新
        let refreshItem = NSMenuItem(title: "刷新", action: #selector(refreshPage), keyEquivalent: "r")
        refreshItem.keyEquivalentModifierMask = [.command]
        refreshItem.target = self
        menu.addItem(refreshItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 返回
        let backItem = NSMenuItem(title: "返回", action: #selector(goBackPage), keyEquivalent: "[")
        backItem.keyEquivalentModifierMask = [.command]
        backItem.target = self
        backItem.isEnabled = canGoBack
        menu.addItem(backItem)
        
        // 前进
        let forwardItem = NSMenuItem(title: "前进", action: #selector(goForwardPage), keyEquivalent: "]")
        forwardItem.keyEquivalentModifierMask = [.command]
        forwardItem.target = self
        forwardItem.isEnabled = canGoForward
        menu.addItem(forwardItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 复制选中文本
        let copyItem = NSMenuItem(title: "复制选中文本", action: #selector(copySelectedText), keyEquivalent: "c")
        copyItem.keyEquivalentModifierMask = [.command]
        copyItem.target = self
        menu.addItem(copyItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 打开调试工具
        let inspectorItem = NSMenuItem(title: "打开调试工具", action: #selector(openInspector), keyEquivalent: "i")
        inspectorItem.keyEquivalentModifierMask = [.command, .option]
        inspectorItem.target = self
        menu.addItem(inspectorItem)
        
        // 显示菜单
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
    
    @objc private func refreshPage() {
        print("🔄 刷新页面")
        reload()
    }
    
    @objc private func goBackPage() {
        print("⬅️ 返回上一页")
        goBack()
    }
    
    @objc private func goForwardPage() {
        print("➡️ 前进下一页")
        goForward()
    }
    
    @objc private func copySelectedText() {
        print("📋 复制选中文本")
        // 执行 JavaScript 来获取选中的文本
        evaluateJavaScript("window.getSelection().toString()") { result, error in
            if let selectedText = result as? String, !selectedText.isEmpty {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(selectedText, forType: .string)
                print("✅ 已复制文本: \(selectedText.prefix(50))...")
            } else {
                print("ℹ️ 没有选中的文本")
            }
        }
    }
    
    @objc private func openInspector() {
        print("🔍 打开调试工具")
        
        // 启用开发者工具
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        
        // 简化实现：不显示弹窗，直接在控制台输出提示
        evaluateJavaScript("""
            console.log('%c🔧 调试工具已启用！', 'color: #00ff00; font-size: 18px; font-weight: bold;');
            console.log('%c💡 使用方法：', 'color: #0066cc; font-size: 14px; font-weight: bold;');
            console.log('• 右键点击页面元素选择"检查元素"');
            console.log('• 使用快捷键 ⌘⌥I');
            console.log('• 按 F12 键');
            console.log('%c🎯 调试工具现已可用！', 'color: #ff6600; font-size: 14px;');
        """) { _, _ in }
        
        print("✅ 调试工具已启用，无弹窗提示")
    }
}

struct PersistentWebView: NSViewRepresentable {
    let url: URL
    let isVisible: Bool
    let onLoadingStateChange: (Bool) -> Void
    let onFirstContentLoad: () -> Void
    let onLoadError: (Error) -> Void
    
    func makeNSView(context: Context) -> CustomWKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true
        // 启用开发者工具
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        
        // 优化 WebView 设置，减少不必要的弹窗
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        configuration.allowsAirPlayForMediaPlayback = false
        
        let webView = CustomWKWebView(frame: .zero, configuration: configuration)
        
        // 设置自定义 User Agent，让 WebView 伪装成标准的 macOS Safari 浏览器
        // 这会告诉网页服务器（如Google）下发功能最完整的桌面版JavaScript代码
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        // 初始加载
        print("🆕 创建新的 WebView 并加载: \(url.absoluteString)")
        let request = URLRequest(url: url)
        webView.load(request)
        
        // 标记为已初始化
        context.coordinator.hasInitiallyLoaded = true
        
        return webView
    }
    
    func updateNSView(_ nsView: CustomWKWebView, context: Context) {
        // 更新协调器的回调
        context.coordinator.onLoadingStateChange = onLoadingStateChange
        context.coordinator.onFirstContentLoad = onFirstContentLoad
        context.coordinator.onLoadError = onLoadError
        
        // 只有在 WebView 从未加载过且为空时才进行加载
        // 避免因为状态变化（如可见性）而重新加载页面
        if !context.coordinator.hasInitiallyLoaded && nsView.url == nil {
            print("📱 WebView 首次加载: \(url.absoluteString)")
            let request = URLRequest(url: url)
            nsView.load(request)
            context.coordinator.hasInitiallyLoaded = true
        } else {
            print("📱 WebView 已存在，保持状态: \(nsView.url?.absoluteString ?? "未知")")
        }
        
        // 根据可见性控制性能（但不重新加载）
        if !isVisible {
            // 当容器隐藏时，可以考虑暂停一些操作
            // 但绝不重新加载 WebView
            print("📱 WebView 容器隐藏，保持后台状态")
        } else {
            print("📱 WebView 容器可见，恢复前台状态")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            onLoadingStateChange: onLoadingStateChange,
            onFirstContentLoad: onFirstContentLoad,
            onLoadError: onLoadError
        )
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var onLoadingStateChange: (Bool) -> Void
        var onFirstContentLoad: () -> Void
        var onLoadError: (Error) -> Void
        var hasInitiallyLoaded = false
        var hasShownFirstContent = false
        
        init(onLoadingStateChange: @escaping (Bool) -> Void, 
             onFirstContentLoad: @escaping () -> Void,
             onLoadError: @escaping (Error) -> Void) {
            self.onLoadingStateChange = onLoadingStateChange
            self.onFirstContentLoad = onFirstContentLoad
            self.onLoadError = onLoadError
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("🌐 开始加载页面: \(webView.url?.absoluteString ?? "未知")")
            onLoadingStateChange(true)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ 页面加载完成: \(webView.url?.absoluteString ?? "未知")")
            onLoadingStateChange(false)
            
            // 延迟一点时间后再隐藏加载覆盖层，确保页面内容已渲染
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !self.hasShownFirstContent {
                    self.hasShownFirstContent = true
                    self.onFirstContentLoad()
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ 页面加载失败: \(error.localizedDescription)")
            onLoadingStateChange(false)
            onLoadError(error)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ 页面预加载失败: \(error.localizedDescription)")
            onLoadingStateChange(false)
            onLoadError(error)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            print("🔗 请求导航到: \(navigationAction.request.url?.absoluteString ?? "未知")")
            decisionHandler(.allow)
        }
    }
}