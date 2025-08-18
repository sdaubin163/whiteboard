import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    let url: URL
    @ObservedObject private var proxyManager = ProxyManager.shared
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true
        
        // 应用代理设置到WebView配置
        configureProxyForWebView(configuration)
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        print("正在加载 URL: \(url.absoluteString)")
        
        if nsView.url != url {
            let request = URLRequest(url: url)
            nsView.load(request)
        }
    }
    
    // 为WebView配置代理设置
    private func configureProxyForWebView(_ configuration: WKWebViewConfiguration) {
        guard let proxyConfig = proxyManager.currentProxyConfiguration else {
            return
        }
        
        // 创建代理配置字典
        var proxyDict: [AnyHashable: Any] = [:]
        
        switch proxyConfig.type {
        case .http:
            proxyDict[kCFNetworkProxiesHTTPEnable] = true
            proxyDict[kCFNetworkProxiesHTTPProxy] = proxyConfig.host
            proxyDict[kCFNetworkProxiesHTTPPort] = proxyConfig.port
        case .https:
            proxyDict[kCFNetworkProxiesHTTPSEnable] = true
            proxyDict[kCFNetworkProxiesHTTPSProxy] = proxyConfig.host
            proxyDict[kCFNetworkProxiesHTTPSPort] = proxyConfig.port
        case .socks5:
            proxyDict[kCFNetworkProxiesSOCKSEnable] = true
            proxyDict[kCFNetworkProxiesSOCKSProxy] = proxyConfig.host
            proxyDict[kCFNetworkProxiesSOCKSPort] = proxyConfig.port
        }
        
        // 注意：WKWebView的代理配置相对复杂，这里提供基础配置
        // 实际的代理设置需要通过URLSessionConfiguration或系统级配置来实现
        print("🌐 WebView代理配置: \(proxyConfig.host):\(proxyConfig.port) (\(proxyConfig.type.rawValue))")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("开始加载页面: \(webView.url?.absoluteString ?? "未知")")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("页面加载完成: \(webView.url?.absoluteString ?? "未知")")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("页面加载失败: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("页面预加载失败: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            print("请求导航到: \(navigationAction.request.url?.absoluteString ?? "未知")")
            decisionHandler(.allow)
        }
    }
}