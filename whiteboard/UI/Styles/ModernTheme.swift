import SwiftUI

struct ModernTheme {
    // 主题模式枚举
    enum ThemeMode: String, CaseIterable {
        case system = "系统"
        case light = "浅色"
        case dark = "深色"
    }
    
    // 当前主题模式（可以从配置读取）
    static var currentMode: ThemeMode = .dark // 默认深色模式
    
    // Xcode 风格的现代配色
    static let accentBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let lightGray = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let mediumGray = Color(red: 0.85, green: 0.85, blue: 0.85)
    static let darkGray = Color(red: 0.25, green: 0.25, blue: 0.25)
    
    // 深色模式专用颜色
    static let darkBackground = Color(red: 0.11, green: 0.11, blue: 0.12) // 类似 Xcode 深色背景
    static let darkSidebar = Color(red: 0.16, green: 0.16, blue: 0.17)
    static let darkContent = Color(red: 0.19, green: 0.19, blue: 0.20)
    static let darkSeparator = Color(red: 0.28, green: 0.28, blue: 0.29)
    static let darkPrimaryText = Color(red: 0.96, green: 0.96, blue: 0.96)
    static let darkSecondaryText = Color(red: 0.78, green: 0.78, blue: 0.78)
    
    // 背景色 - 根据主题模式返回对应颜色
    static var sidebarBackground: Color {
        switch currentMode {
        case .system:
            return Color(NSColor.controlBackgroundColor)
        case .light:
            return Color(NSColor.controlBackgroundColor)
        case .dark:
            return darkSidebar
        }
    }
    
    static var contentBackground: Color {
        switch currentMode {
        case .system:
            return Color(NSColor.textBackgroundColor)
        case .light:
            return Color(NSColor.textBackgroundColor)
        case .dark:
            return darkContent
        }
    }
    
    static var windowBackground: Color {
        switch currentMode {
        case .system:
            return Color(NSColor.windowBackgroundColor)
        case .light:
            return Color(NSColor.windowBackgroundColor)
        case .dark:
            return darkBackground
        }
    }
    
    // 分隔线
    static var separatorColor: Color {
        switch currentMode {
        case .system:
            return Color(NSColor.separatorColor)
        case .light:
            return Color(NSColor.separatorColor)
        case .dark:
            return darkSeparator
        }
    }
    
    // 文字颜色
    static var primaryText: Color {
        switch currentMode {
        case .system:
            return Color(NSColor.labelColor)
        case .light:
            return Color(NSColor.labelColor)
        case .dark:
            return darkPrimaryText
        }
    }
    
    static var secondaryText: Color {
        switch currentMode {
        case .system:
            return Color(NSColor.secondaryLabelColor)
        case .light:
            return Color(NSColor.secondaryLabelColor)
        case .dark:
            return darkSecondaryText
        }
    }
    
    static var tertiaryText: Color {
        switch currentMode {
        case .system:
            return Color(NSColor.tertiaryLabelColor)
        case .light:
            return Color(NSColor.tertiaryLabelColor)
        case .dark:
            return darkSecondaryText.opacity(0.8)
        }
    }
    
    // 控件颜色
    static var controlBackground: Color {
        switch currentMode {
        case .system:
            return Color(NSColor.controlColor)
        case .light:
            return Color(NSColor.controlColor)
        case .dark:
            return Color(red: 0.24, green: 0.24, blue: 0.26)
        }
    }
    
    static var selectedBackground: Color {
        switch currentMode {
        case .system:
            return Color(NSColor.selectedControlColor)
        case .light:
            return Color(NSColor.selectedControlColor)
        case .dark:
            return accentBlue.opacity(0.3)
        }
    }
    
    static var hoverBackground: Color {
        switch currentMode {
        case .system:
            return Color(NSColor.controlAccentColor).opacity(0.1)
        case .light:
            return Color(NSColor.controlAccentColor).opacity(0.1)
        case .dark:
            return accentBlue.opacity(0.15)
        }
    }
    
    // 更新主题模式
    static func updateTheme(to mode: ThemeMode) {
        currentMode = mode
        NotificationCenter.default.post(name: .themeChanged, object: mode)
    }
}

extension Color {
    // 便捷访问
    static let xcodeSidebar = ModernTheme.sidebarBackground
    static let xcodeContent = ModernTheme.contentBackground
    static let xcodeWindow = ModernTheme.windowBackground
    static let xcodeAccent = ModernTheme.accentBlue
    static let xcodeSeparator = ModernTheme.separatorColor
}