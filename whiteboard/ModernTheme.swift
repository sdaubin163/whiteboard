import SwiftUI

struct ModernTheme {
    // 主要配色
    static let primaryBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let primaryPurple = Color(red: 0.55, green: 0.27, blue: 0.95)
    static let primaryCyan = Color(red: 0.0, green: 0.8, blue: 0.95)
    
    // 背景色
    static let darkBackground = Color(red: 0.08, green: 0.09, blue: 0.12)
    static let cardBackground = Color(red: 0.12, green: 0.14, blue: 0.18)
    static let sidebarBackground = Color(red: 0.06, green: 0.07, blue: 0.10)
    
    // 渐变色
    static let primaryGradient = LinearGradient(
        colors: [primaryBlue, primaryPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [darkBackground, Color(red: 0.10, green: 0.12, blue: 0.16)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glowGradient = RadialGradient(
        colors: [primaryCyan.opacity(0.3), Color.clear],
        center: .center,
        startRadius: 0,
        endRadius: 100
    )
    
    // 文字颜色
    static let primaryText = Color.white
    static let secondaryText = Color(red: 0.7, green: 0.7, blue: 0.8)
    static let accentText = primaryCyan
}

extension Color {
    static let modernBlue = ModernTheme.primaryBlue
    static let modernPurple = ModernTheme.primaryPurple
    static let modernCyan = ModernTheme.primaryCyan
    static let modernDark = ModernTheme.darkBackground
    static let modernCard = ModernTheme.cardBackground
    static let modernSidebar = ModernTheme.sidebarBackground
}