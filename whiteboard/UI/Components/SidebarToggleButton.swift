import SwiftUI

struct SidebarToggleButton: View {
    @Binding var isSidebarVisible: Bool
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.25)) {
                isSidebarVisible.toggle()
            }
        }) {
            Image(systemName: "sidebar.left")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(ModernTheme.primaryText)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(isHovered ? ModernTheme.hoverBackground : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .help(isSidebarVisible ? "隐藏侧边栏" : "显示侧边栏")
    }
}