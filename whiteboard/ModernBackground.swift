import SwiftUI

struct ModernBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // 主背景渐变
            ModernTheme.backgroundGradient
                .ignoresSafeArea()
            
            // 动态光效
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ModernTheme.primaryCyan.opacity(0.15),
                                ModernTheme.primaryBlue.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(
                        x: animateGradient ? CGFloat.random(in: -200...200) : CGFloat.random(in: -100...100),
                        y: animateGradient ? CGFloat.random(in: -200...200) : CGFloat.random(in: -100...100)
                    )
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 8...12))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 2),
                        value: animateGradient
                    )
            }
            
            // 网格背景效果
            Canvas { context, size in
                let spacing: CGFloat = 50
                let rows = Int(size.height / spacing) + 1
                let cols = Int(size.width / spacing) + 1
                
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * spacing
                        let y = CGFloat(row) * spacing
                        let point = CGPoint(x: x, y: y)
                        
                        context.fill(
                            Circle().path(in: CGRect(origin: point, size: CGSize(width: 1, height: 1))),
                            with: .color(ModernTheme.primaryCyan.opacity(0.1))
                        )
                    }
                }
            }
            .opacity(0.3)
        }
        .onAppear {
            animateGradient = true
        }
    }
}

struct GlassPanel: View {
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .background(
                ModernTheme.cardBackground.opacity(0.3)
            )
            .overlay(
                Rectangle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                ModernTheme.primaryCyan.opacity(0.5),
                                Color.clear,
                                ModernTheme.primaryBlue.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}