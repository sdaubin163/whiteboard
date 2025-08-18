import Foundation
import Network

// 代理管理器 - 处理应用级别的代理设置
class ProxyManager: ObservableObject {
    static let shared = ProxyManager()
    
    @Published var isProxyActive: Bool = false
    @Published var currentProxyConfiguration: ProxyConfiguration?
    
    private init() {}
    
    // 代理配置结构
    struct ProxyConfiguration {
        let type: ProxyType
        let host: String
        let port: Int
        let username: String?
        let password: String?
        
        enum ProxyType: String, CaseIterable {
            case http = "HTTP"
            case https = "HTTPS"
            case socks5 = "SOCKS5"
        }
    }
    
    // 配置代理
    func configureProxy(type: String, host: String, port: Int, username: String?, password: String?) {
        guard let proxyType = ProxyConfiguration.ProxyType(rawValue: type) else {
            print("❌ 不支持的代理类型: \(type)")
            return
        }
        
        let configuration = ProxyConfiguration(
            type: proxyType,
            host: host,
            port: port,
            username: username,
            password: password
        )
        
        self.currentProxyConfiguration = configuration
        self.isProxyActive = true
        
        // 设置URLSession默认配置
        configureURLSessionProxy(configuration)
        
        print("✅ 代理配置已激活: \(host):\(port) (\(type))")
    }
    
    // 禁用代理
    func disableProxy() {
        self.currentProxyConfiguration = nil
        self.isProxyActive = false
        
        // 清除URLSession代理配置
        clearURLSessionProxy()
        
        print("🚫 代理已禁用")
    }
    
    // 配置URLSession的代理设置
    private func configureURLSessionProxy(_ configuration: ProxyConfiguration) {
        let config = URLSessionConfiguration.default
        
        // 设置代理字典
        var proxyDict: [AnyHashable: Any] = [:]
        
        switch configuration.type {
        case .http:
            proxyDict[kCFNetworkProxiesHTTPEnable] = true
            proxyDict[kCFNetworkProxiesHTTPProxy] = configuration.host
            proxyDict[kCFNetworkProxiesHTTPPort] = configuration.port
        case .https:
            proxyDict[kCFNetworkProxiesHTTPSEnable] = true
            proxyDict[kCFNetworkProxiesHTTPSProxy] = configuration.host
            proxyDict[kCFNetworkProxiesHTTPSPort] = configuration.port
        case .socks5:
            proxyDict[kCFNetworkProxiesSOCKSEnable] = true
            proxyDict[kCFNetworkProxiesSOCKSProxy] = configuration.host
            proxyDict[kCFNetworkProxiesSOCKSPort] = configuration.port
        }
        
        config.connectionProxyDictionary = proxyDict
        
        // 更新默认会话配置
        updateDefaultURLSessionConfiguration(config)
    }
    
    // 清除URLSession代理配置
    private func clearURLSessionProxy() {
        let config = URLSessionConfiguration.default
        config.connectionProxyDictionary = nil
        updateDefaultURLSessionConfiguration(config)
    }
    
    // 更新默认URLSession配置（这将影响WebView和其他网络请求）
    private func updateDefaultURLSessionConfiguration(_ config: URLSessionConfiguration) {
        // 通过设置全局的URLSession配置来影响应用内的网络请求
        // 注意：这主要影响通过URLSession发起的请求
        
        // 发送代理配置变更通知
        NotificationCenter.default.post(
            name: .proxyConfigurationChanged,
            object: currentProxyConfiguration
        )
    }
    
    // 创建支持代理的URLSession
    func createProxyEnabledURLSession() -> URLSession {
        let config = URLSessionConfiguration.default
        
        if let proxyConfig = currentProxyConfiguration {
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
            
            config.connectionProxyDictionary = proxyDict
        }
        
        return URLSession(configuration: config)
    }
    
    // 测试代理连接
    func testProxyConnection(completion: @escaping (Bool, String) -> Void) {
        guard let proxyConfig = currentProxyConfiguration else {
            completion(false, "未配置代理")
            return
        }
        
        // 创建测试用的URLSession
        let session = createProxyEnabledURLSession()
        
        // 测试连接到常见的测试URL
        guard let url = URL(string: "https://httpbin.org/ip") else {
            completion(false, "测试URL无效")
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, "连接失败: \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        completion(true, "代理连接正常")
                    } else {
                        completion(false, "HTTP状态码: \(httpResponse.statusCode)")
                    }
                } else {
                    completion(false, "未知响应")
                }
            }
        }
        
        task.resume()
        
        // 设置10秒超时
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            task.cancel()
            completion(false, "连接超时")
        }
    }
}

// 通知名称扩展
extension Notification.Name {
    static let proxyConfigurationChanged = Notification.Name("proxyConfigurationChanged")
}