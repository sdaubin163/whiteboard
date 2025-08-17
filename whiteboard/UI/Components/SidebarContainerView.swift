import SwiftUI

struct SidebarContainerView: View {
    @ObservedObject var appModel: AppModel
    @Binding var isSidebarVisible: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 侧边栏内容
            VStack(spacing: 8) {
                // 应用按钮
                ForEach(appModel.apps) { app in
                    SidebarButton(
                        icon: app.icon,
                        isSystemIcon: app.isSystemIcon,
                        isSelected: appModel.selectedApp?.id == app.id
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            appModel.selectAppWithPersistence(app)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.top, 16)
            .padding(.horizontal, 8)
        }
        .frame(width: 48)
        .background(SidebarPanel())
        .transition(.move(edge: .leading).combined(with: .opacity))
    }
}