import SwiftUI

struct ModernTheme {
    // Xcode 风格的现代配色
    static let accentBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let lightGray = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let mediumGray = Color(red: 0.85, green: 0.85, blue: 0.85)
    static let darkGray = Color(red: 0.25, green: 0.25, blue: 0.25)
    
    // 背景色 - 支持浅色和深色模式
    static let sidebarBackground = Color(NSColor.controlBackgroundColor)
    static let contentBackground = Color(NSColor.textBackgroundColor)
    static let windowBackground = Color(NSColor.windowBackgroundColor)
    
    // 分隔线
    static let separatorColor = Color(NSColor.separatorColor)
    
    // 文字颜色
    static let primaryText = Color(NSColor.labelColor)
    static let secondaryText = Color(NSColor.secondaryLabelColor)
    static let tertiaryText = Color(NSColor.tertiaryLabelColor)
    
    // 控件颜色
    static let controlBackground = Color(NSColor.controlColor)
    static let selectedBackground = Color(NSColor.selectedControlColor)
    static let hoverBackground = Color(NSColor.controlAccentColor).opacity(0.1)
}

extension Color {
    // 便捷访问
    static let xcodeSidebar = ModernTheme.sidebarBackground
    static let xcodeContent = ModernTheme.contentBackground
    static let xcodeWindow = ModernTheme.windowBackground
    static let xcodeAccent = ModernTheme.accentBlue
    static let xcodeSeparator = ModernTheme.separatorColor
}