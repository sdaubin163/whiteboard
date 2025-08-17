import SwiftUI

struct SidebarButton: View {
    let icon: String
    let isSystemIcon: Bool
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    init(icon: String, isSystemIcon: Bool = true, isSelected: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.isSystemIcon = isSystemIcon
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                // 图标
                Group {
                    if isSystemIcon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                    } else {
                        Text(icon)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
            }
            .background(backgroundFill)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor, lineWidth: isSelected ? 1 : 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
    
    private var backgroundFill: Color {
        if isSelected {
            return ModernTheme.selectedBackground
        } else if isHovered {
            return ModernTheme.hoverBackground
        } else {
            return Color.clear
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return ModernTheme.accentBlue
        } else {
            return Color.clear
        }
    }
    
    private var iconColor: Color {
        if isSelected {
            return ModernTheme.accentBlue
        } else if isHovered {
            return ModernTheme.primaryText
        } else {
            return ModernTheme.secondaryText
        }
    }
}