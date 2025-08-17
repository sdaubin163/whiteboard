import SwiftUI

struct ModernBackground: View {
    var body: some View {
        // 简洁的系统背景
        ModernTheme.windowBackground
            .ignoresSafeArea()
    }
}

struct SidebarPanel: View {
    var body: some View {
        Rectangle()
            .fill(ModernTheme.sidebarBackground)
            .overlay(
                Rectangle()
                    .stroke(ModernTheme.separatorColor, lineWidth: 1)
                    .opacity(0.5)
            )
    }
}

struct ContentPanel: View {
    var body: some View {
        Rectangle()
            .fill(ModernTheme.contentBackground)
            .overlay(
                Rectangle()
                    .stroke(ModernTheme.separatorColor, lineWidth: 1)
                    .opacity(0.5)
            )
    }
}