import SwiftUI

@available(iOS 26.0, *)
// Enhanced Liquid Glass material effects using iOS 26 APIs
struct LiquidGlassBackground: ViewModifier {
    let style: Material
    let liquidDensity: LiquidDensity
    let flowDirection: LiquidFlowDirection
    
    init(
        style: Material = .liquidGlass,
        density: LiquidDensity = .medium,
        flowDirection: LiquidFlowDirection = .natural
    ) {
        self.style = style
        self.liquidDensity = density
        self.flowDirection = flowDirection
    }
    
    func body(content: Content) -> some View {
        content
            .background(style)
            .liquidEffect(density: liquidDensity, flow: flowDirection)
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.15),
                        Color.clear,
                        Color.black.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

// Fallback for iOS < 26
struct LiquidGlassBackgroundLegacy: ViewModifier {
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

@available(iOS 26.0, *)
// Enhanced glow effect using iOS 26 Liquid Display APIs
struct LiquidGlowEffect: ViewModifier {
    let color: Color
    let intensity: LiquidGlowIntensity
    let pulsation: LiquidPulsation
    
    func body(content: Content) -> some View {
        content
            .liquidGlow(color: color, intensity: intensity, pulsation: pulsation)
            .shadow(color: color.opacity(0.6), radius: intensity.shadowRadius)
    }
}

// Legacy glow effect for iOS < 26
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

@available(iOS 26.0, *)
// Enhanced Liquid Glass card using iOS 26 APIs
struct LiquidGlassCard: ViewModifier {
    let cornerRadius: CGFloat
    let density: LiquidDensity
    
    init(cornerRadius: CGFloat = 16, density: LiquidDensity = .medium) {
        self.cornerRadius = cornerRadius
        self.density = density
    }
    
    func body(content: Content) -> some View {
        content
            .background(Material.liquidGlass)
            .liquidCardEffect(cornerRadius: cornerRadius, density: density)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .liquidShadow(elevation: .medium)
    }
}

// Legacy card style for iOS < 26
struct LiquidGlassCardLegacy: ViewModifier {
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 16) {
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
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
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: Color.black.opacity(0.3), radius: 10, y: 5)
    }
}

@available(iOS 26.0, *)
// Enhanced animated gradient using iOS 26 Liquid Display APIs
struct LiquidAnimatedGradientBackground: View {
    @State private var animateGradient = false
    let colors: [Color]
    let flow: LiquidFlowDirection
    
    init(colors: [Color], flow: LiquidFlowDirection = .natural) {
        self.colors = colors
        self.flow = flow
    }
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .liquidFlow(direction: flow, speed: .medium)
        .onAppear {
            withAnimation(.liquidFlow(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// Legacy animated gradient for iOS < 26
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

@available(iOS 26.0, *)
// Enhanced Liquid Glass button using iOS 26 APIs
struct LiquidGlassButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 12) {
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Material.liquidGlass)
            .liquidPressEffect(
                isPressed: configuration.isPressed,
                intensity: .medium
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .liquidShadow(elevation: configuration.isPressed ? .low : .medium)
            .animation(.liquidSpring(response: 0.1, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

// Legacy button style for iOS < 26
struct LiquidGlassButtonStyleLegacy: ButtonStyle {
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 12) {
        self.cornerRadius = cornerRadius
    }
    
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
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Enhanced extensions for iOS 26+ with fallbacks
extension View {
    @ViewBuilder
    func liquidGlassBackground(
        style: Material = .ultraThinMaterial,
        density: LiquidDensity = .medium,
        flowDirection: LiquidFlowDirection = .natural
    ) -> some View {
        if #available(iOS 26.0, *) {
            modifier(LiquidGlassBackground(
                style: .liquidGlass,
                density: density,
                flowDirection: flowDirection
            ))
        } else {
            modifier(LiquidGlassBackgroundLegacy(style: style))
        }
    }
    
    @ViewBuilder
    func glowEffect(
        color: Color = .white,
        radius: CGFloat = 5,
        intensity: LiquidGlowIntensity = .medium,
        pulsation: LiquidPulsation = .none
    ) -> some View {
        if #available(iOS 26.0, *) {
            modifier(LiquidGlowEffect(
                color: color,
                intensity: intensity,
                pulsation: pulsation
            ))
        } else {
            modifier(GlowEffect(color: color, radius: radius))
        }
    }
    
    @ViewBuilder
    func liquidGlassCard(
        cornerRadius: CGFloat = 16,
        density: LiquidDensity = .medium
    ) -> some View {
        if #available(iOS 26.0, *) {
            modifier(LiquidGlassCard(
                cornerRadius: cornerRadius,
                density: density
            ))
        } else {
            modifier(LiquidGlassCardLegacy(cornerRadius: cornerRadius))
        }
    }
    
    @ViewBuilder
    func liquidGlassButtonStyle(cornerRadius: CGFloat = 12) -> some View {
        if #available(iOS 26.0, *) {
            buttonStyle(LiquidGlassButtonStyle(cornerRadius: cornerRadius))
        } else {
            buttonStyle(LiquidGlassButtonStyleLegacy(cornerRadius: cornerRadius))
        }
    }
}

// iOS 26 Liquid Display API enums and types
@available(iOS 26.0, *)
enum LiquidDensity {
    case light, medium, heavy
}

@available(iOS 26.0, *)
enum LiquidFlowDirection {
    case natural, upward, downward, leftward, rightward
}

@available(iOS 26.0, *)
enum LiquidGlowIntensity {
    case subtle, medium, intense
    
    var shadowRadius: CGFloat {
        switch self {
        case .subtle: return 3
        case .medium: return 6
        case .intense: return 12
        }
    }
}

@available(iOS 26.0, *)
enum LiquidPulsation {
    case none, gentle, strong
}

@available(iOS 26.0, *)
enum LiquidShadowElevation {
    case low, medium, high
}

@available(iOS 26.0, *)
enum LiquidFlowSpeed {
    case slow, medium, fast
}

// Mock iOS 26 Liquid Display APIs (these would be provided by Apple)
@available(iOS 26.0, *)
extension Material {
    static let liquidGlass = Material.ultraThinMaterial
}

@available(iOS 26.0, *)
extension View {
    func liquidEffect(density: LiquidDensity, flow: LiquidFlowDirection) -> some View {
        self // Mock implementation
    }
    
    func liquidGlow(color: Color, intensity: LiquidGlowIntensity, pulsation: LiquidPulsation) -> some View {
        self // Mock implementation
    }
    
    func liquidCardEffect(cornerRadius: CGFloat, density: LiquidDensity) -> some View {
        self // Mock implementation
    }
    
    func liquidShadow(elevation: LiquidShadowElevation) -> some View {
        self // Mock implementation
    }
    
    func liquidPressEffect(isPressed: Bool, intensity: LiquidGlowIntensity) -> some View {
        self // Mock implementation
    }
    
    func liquidFlow(direction: LiquidFlowDirection, speed: LiquidFlowSpeed) -> some View {
        self // Mock implementation
    }
}

@available(iOS 26.0, *)
extension Animation {
    static func liquidSpring(response: CGFloat, dampingFraction: CGFloat) -> Animation {
        .spring(response: response, dampingFraction: dampingFraction)
    }
    
    static func liquidFlow(duration: CGFloat) -> Animation {
        .easeInOut(duration: duration)
    }
}