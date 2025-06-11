import SwiftUI

// Liquid Glass material effects
struct LiquidGlassBackground: ViewModifier {
    let style: Material
    
    init(style: Material = .ultraThinMaterial) {
        self.style = style
    }
    
    func body(content: Content) -> some View {
        content
            .background(style)
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.1),
                        Color.clear,
                        Color.black.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

// Glow effect for live indicators
struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.8), radius: radius)
            .shadow(color: color.opacity(0.4), radius: radius * 2)
            .shadow(color: color.opacity(0.2), radius: radius * 3)
    }
}

// Liquid Glass card style
struct LiquidGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.3), radius: 10, y: 5)
    }
}

// Animated gradient background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    let colors: [Color]
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// Liquid Glass button style
struct LiquidGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                Group {
                    if configuration.isPressed {
                        Color.white.opacity(0.2)
                    } else {
                        Color.white.opacity(0.1)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Extensions for easy use
extension View {
    func liquidGlassBackground(style: Material = .ultraThinMaterial) -> some View {
        modifier(LiquidGlassBackground(style: style))
    }
    
    func glowEffect(color: Color = .white, radius: CGFloat = 5) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
    
    func liquidGlassCard() -> some View {
        modifier(LiquidGlassCard())
    }
}