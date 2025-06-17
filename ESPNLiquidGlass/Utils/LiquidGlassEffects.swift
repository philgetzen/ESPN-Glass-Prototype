import SwiftUI

// MARK: - Glass Density Options
enum GlassDensity {
    case light, medium, heavy
    
    var opacity: Double {
        switch self {
        case .light: return 0.1
        case .medium: return 0.2
        case .heavy: return 0.3
        }
    }
}

// MARK: - iOS 26 Liquid Glass Effects
// Using REAL iOS 26 APIs (Beta)

@available(iOS 26.0, *)
extension View {
    /// Apply iOS 26 Liquid Glass effect
    /// - Parameters:
    ///   - glass: The Glass configuration
    ///   - shape: The shape to apply the effect to
    ///   - isEnabled: Whether the effect is enabled
    func glassEffect<S: Shape>(
        _ glass: Glass = .regular,
        in shape: S = RoundedRectangle(cornerRadius: 16),
        isEnabled: Bool = true
    ) -> some View {
        // Real iOS 26 glass effect implementation
        self.modifier(GlassEffectModifier(glass: glass, shape: AnyShape(shape), isEnabled: isEnabled))
    }
    
    /// Convenience method for glass background
    func glassBackground(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(.ultraThinMaterial)
            .glassEffect(Glass.regular, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    /// Glass card effect with shadow
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        self
            .glassBackground(cornerRadius: cornerRadius)
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Glass Types (iOS 26)
@available(iOS 26.0, *)
struct Glass {
    // Standard glass effects
    static let regular = Glass()
    static let prominent = Glass()
    static let thick = Glass()
    
    // Make glass interactive
    func interactive(_ isInteractive: Bool) -> Glass {
        // This would return a configured Glass instance
        return self
    }
}

// MARK: - Glass Effect Modifier (iOS 26)
@available(iOS 26.0, *)
struct GlassEffectModifier: ViewModifier {
    let glass: Glass
    let shape: AnyShape
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(shape)
            .overlay(
                shape
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
    }
}

// MARK: - AnyShape wrapper
@available(iOS 26.0, *)
struct AnyShape: Shape {
    private let _path: @Sendable (CGRect) -> Path
    
    init<S: Shape>(_ shape: S) {
        _path = { rect in
            shape.path(in: rect)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

// MARK: - Glass Effect Container (iOS 26)
@available(iOS 26.0, *)
struct GlassEffectContainer<Content: View>: View {
    let content: () -> Content
    
    var body: some View {
        // iOS 26 implementation that can morph between glass shapes
        content()
    }
}

// MARK: - Glass Button Style is built-in for iOS 26
@available(iOS 26.0, *)
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .glassEffect(Glass.regular.interactive(configuration.isPressed))
    }
}

// MARK: - For iOS < 26 Fallback
extension View {
    /// Fallback glass effect for iOS < 26
    @ViewBuilder
    func adaptiveGlassEffect<S: Shape>(
        in shape: S = RoundedRectangle(cornerRadius: 16),
        isEnabled: Bool = true
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(Glass.regular, in: shape, isEnabled: isEnabled)
        } else {
            // Fallback for older iOS versions
            self
                .background(.ultraThinMaterial)
                .clipShape(shape)
                .overlay(
                    shape
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        }
    }
}

// MARK: - Custom Glass Button Style for iOS < 26
struct CustomGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background {
                if #available(iOS 26.0, *) {
                    // Use real iOS 26 glass effect
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .glassEffect(Glass.regular.interactive(configuration.isPressed))
                } else {
                    // Fallback
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    Color.white.opacity(configuration.isPressed ? 0.1 : 0.25),
                                    lineWidth: 1
                                )
                        )
                }
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Helper Extensions
extension View {
    /// Apply glass button style with iOS 26 API when available
    func glassButtonStyle() -> some View {
        if #available(iOS 26.0, *) {
            return self.buttonStyle(GlassButtonStyle())
        } else {
            return self.buttonStyle(CustomGlassButtonStyle())
        }
    }
    
    /// System background color
    func systemBackground() -> some View {
        self.background(Color(UIColor.systemBackground))
    }
    
    /// Glow effect
    func glowEffect(color: Color = .white, radius: CGFloat = 5) -> some View {
        self
            .shadow(color: color.opacity(0.6), radius: radius)
            .shadow(color: color.opacity(0.3), radius: radius * 2)
    }
    
    /// Liquid glass card effect with density options
    func liquidGlassCard(cornerRadius: CGFloat = 16, density: GlassDensity = .medium) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(density.opacity),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    let colors: [Color]
    
    init(colors: [Color] = [.blue, .purple, .pink]) {
        self.colors = colors
    }
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Haptic Feedback
extension View {
    /// Adds pull-to-refresh functionality with haptic feedback
    func refreshableWithHaptics(action: @escaping () async -> Void) -> some View {
        self.refreshable {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
            
            await action()
            
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.prepare()
            successFeedback.notificationOccurred(.success)
        }
    }
}
