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
            ZStack {
                // 发光背景层
                if isSelected || isHovered {
                    Circle()
                        .fill(ModernTheme.glowGradient)
                        .scaleEffect(1.2)
                        .opacity(isSelected ? 0.6 : 0.3)
                }
                
                // 主背景
                Circle()
                    .fill(backgroundFill)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(borderColor, lineWidth: 1)
                    )
                
                // 图标
                Group {
                    if isSystemIcon {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .medium))
                    } else {
                        Text(icon)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .foregroundColor(iconColor)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : (isHovered ? 1.02 : 1.0))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private var backgroundFill: some ShapeStyle {
        if isSelected {
            return AnyShapeStyle(ModernTheme.primaryGradient)
        } else if isHovered {
            return AnyShapeStyle(ModernTheme.cardBackground.opacity(0.8))
        } else {
            return AnyShapeStyle(ModernTheme.cardBackground.opacity(0.4))
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return ModernTheme.primaryCyan.opacity(0.8)
        } else if isHovered {
            return ModernTheme.primaryCyan.opacity(0.4)
        } else {
            return Color.gray.opacity(0.2)
        }
    }
    
    private var iconColor: Color {
        if isSelected {
            return .white
        } else if isHovered {
            return ModernTheme.accentText
        } else {
            return ModernTheme.secondaryText
        }
    }
}