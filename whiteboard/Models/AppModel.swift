import SwiftUI

struct WebApp: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let isSystemIcon: Bool
    let url: String
    
    init(name: String, icon: String, isSystemIcon: Bool = true, url: String) {
        self.name = name
        self.icon = icon
        self.isSystemIcon = isSystemIcon
        self.url = url
    }
}

class AppModel: ObservableObject {
    @Published var selectedApp: WebApp?
    
    let webApps: [WebApp] = [
        WebApp(name: "Gemini", icon: "sparkles", url: "https://gemini.google.com/app"),
        WebApp(name: "ChatGPT", icon: "message.circle", url: "https://chat.openai.com"),
        WebApp(name: "Claude", icon: "brain.head.profile", url: "https://claude.ai"),
        WebApp(name: "GitHub", icon: "globe", url: "https://github.com"),
        WebApp(name: "Stack Overflow", icon: "questionmark.circle", url: "https://stackoverflow.com"),
        WebApp(name: "Notion", icon: "doc.text", url: "https://notion.so"),
        WebApp(name: "Figma", icon: "paintbrush", url: "https://figma.com"),
        WebApp(name: "Linear", icon: "line.diagonal", url: "https://linear.app")
    ]
    
    init() {
        selectedApp = webApps.first
    }
}