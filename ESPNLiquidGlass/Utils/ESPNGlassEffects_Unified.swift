import SwiftUI

// MARK: - ESPN Glass Effects - Unified Implementation
// This file provides a clean implementation of glass effects for ESPN
// Uses native iOS 18+ Glass APIs when available, with proper fallbacks

// MARK: - ESPN Glass Density Configuration
public enum ESPNGlassDensity: Sendable {
    case light
    case medium
    case heavy
    
    var fallbackOpacity: Double {
        switch self {
        case .light: return 0.1
        case .medium: return 0.2
        case .heavy: return 0.3
        }
    }
    
    @available(iOS 18.0, *)
    var nativeGlass: Glass {
        // iOS 18+ Glass type only has .regular
        // We'll use the same glass with different material backgrounds
        return .regular
    }
}

// MARK: - ESPN Glass Button Style
public struct ESPNGlassButtonStyle: ButtonStyle {
    let density: ESPNGlassDensity
    
    public init(density: ESPNGlassDensity = .medium) {
        self.density = density
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 18.0, *) {
            configuration.label
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .glassEffect(
                    .regular,
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.smooth(duration: 0.2), value: configuration.isPressed)
        } else {
            // Fallback for iOS 17 and earlier
            configuration.label
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
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
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }
}

// MARK: - ESPN Glass Container (iOS 18+ only)
@available(iOS 18.0, *)
public struct ESPNGlassContainer<Content: View>: View {
    let content: () -> Content
    let density: ESPNGlassDensity
    @State private var isPressed = false
    
    public init(
        density: ESPNGlassDensity = .medium,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.density = density
        self.content = content
    }
    
    public var body: some View {
        // Apply different materials based on density
        Group {
            switch density {
            case .light:
                content()
                    .background(.ultraThinMaterial)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
            case .medium:
                content()
                    .background(.thinMaterial)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
            case .heavy:
                content()
                    .background(.regularMaterial)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.smooth(duration: 0.15), value: isPressed)
        .onTapGesture { }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) {
            isPressed = true
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}

// MARK: - ESPN Glass Modifiers
struct ESPNGlassModifier: ViewModifier {
    let density: ESPNGlassDensity
    let cornerRadius: CGFloat
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            // Use different materials to simulate density since Glass only has .regular
            Group {
                switch density {
                case .light:
                    content
                        .background(.ultraThinMaterial)
                        .glassEffect(
                            .regular,
                            in: RoundedRectangle(cornerRadius: cornerRadius),
                            isEnabled: isEnabled
                        )
                case .medium:
                    content
                        .background(.thinMaterial)
                        .glassEffect(
                            .regular,
                            in: RoundedRectangle(cornerRadius: cornerRadius),
                            isEnabled: isEnabled
                        )
                case .heavy:
                    content
                        .background(.regularMaterial)
                        .glassEffect(
                            .regular,
                            in: RoundedRectangle(cornerRadius: cornerRadius),
                            isEnabled: isEnabled
                        )
                }
            }
        } else {
            // Fallback implementation
            Group {
                if isEnabled {
                    content
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3 * density.fallbackOpacity * 3),
                                            Color.white.opacity(0.1 * density.fallbackOpacity * 3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                } else {
                    content
                }
            }
        }
    }
}

// MARK: - Live Game Glass Effect
public struct ESPNLiveGameGlassModifier: ViewModifier {
    let isLive: Bool
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(
                        LinearGradient(
                            colors: [
                                isLive ? Color.red.opacity(0.3) : Color.clear,
                                isLive ? Color.red.opacity(0.1) : Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: isLive ? 2 : 0
                    )
                    .animation(.easeInOut(duration: 0.3), value: isLive)
            )
    }
}

// MARK: - Main View Extensions
public extension View {
    /// Apply ESPN glass effect with automatic iOS version handling
    func espnGlassEffect(
        density: ESPNGlassDensity = .medium,
        cornerRadius: CGFloat = 16,
        isEnabled: Bool = true
    ) -> some View {
        self.modifier(ESPNGlassModifier(
            density: density,
            cornerRadius: cornerRadius,
            isEnabled: isEnabled
        ))
    }
    
    /// ESPN glass card effect with shadows
    func espnGlassCard(
        cornerRadius: CGFloat = 16,
        density: ESPNGlassDensity = .medium
    ) -> some View {
        self
            .espnGlassEffect(
                density: density,
                cornerRadius: cornerRadius
            )
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
    
    /// Apply ESPN glass button style
    func espnGlassButtonStyle(density: ESPNGlassDensity = .medium) -> some View {
        self.buttonStyle(ESPNGlassButtonStyle(density: density))
    }
    
    /// ESPN glass toolbar configuration
    func espnGlassToolbar() -> some View {
        self
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }
    
    /// ESPN glass loading overlay
    @ViewBuilder
    func espnGlassLoadingOverlay(isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                        
                        Text("Loading...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(24)
                    .espnGlassCard(cornerRadius: 16)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
    
    /// Apply live game glass effect
    func espnLiveGameGlass(isLive: Bool) -> some View {
        self.modifier(ESPNLiveGameGlassModifier(isLive: isLive))
    }
    
    /// System background color helper
    func systemBackground() -> some View {
        self.background(Color(UIColor.systemBackground))
    }
    
    /// Glow effect
    func glowEffect(color: Color = .white, radius: CGFloat = 5) -> some View {
        self
            .shadow(color: color.opacity(0.6), radius: radius)
            .shadow(color: color.opacity(0.3), radius: radius * 2)
    }
    
    /// Haptic feedback on refresh
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

// MARK: - Performance Optimizations (iOS 18+)
@available(iOS 18.0, *)
public extension View {
    /// Optimize glass effects for complex view hierarchies
    func espnOptimizedGlass(density: ESPNGlassDensity = .medium) -> some View {
        self
            .drawingGroup() // Flatten the view hierarchy
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
    }
    
    /// Apply glass effect with GPU acceleration
    func espnGPUAcceleratedGlass(density: ESPNGlassDensity = .medium) -> some View {
        self
            .compositingGroup()
            .glassEffect(.regular)
    }
}

// MARK: - Animated Gradient Background
public struct ESPNAnimatedGradientBackground: View {
    @State private var animateGradient = false
    let colors: [Color]
    
    public init(colors: [Color] = [.blue, .purple, .pink]) {
        self.colors = colors
    }
    
    public var body: some View {
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

// MARK: - ESPN Glass Effect Transition
public struct ESPNGlassEffectTransition: Sendable {
    let animation: Animation
    
    public static let opacity = ESPNGlassEffectTransition(animation: .easeInOut(duration: 0.3))
    public static let scale = ESPNGlassEffectTransition(animation: .spring())
    public static let slide = ESPNGlassEffectTransition(animation: .easeOut(duration: 0.25))
}

// MARK: - Glass Card Component
public struct GlassCard<Content: View>: View {
    let content: () -> Content
    let cornerRadius: CGFloat
    let density: ESPNGlassDensity
    
    public init(
        cornerRadius: CGFloat = 16,
        density: ESPNGlassDensity = .medium,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.density = density
        self.content = content
    }
    
    public var body: some View {
        content()
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .espnGlassCard(cornerRadius: cornerRadius, density: density)
    }
}

// MARK: - ESPN Glass Card (Alternative)
public struct ESPNGlassCard<Content: View>: View {
    let content: () -> Content
    let cornerRadius: CGFloat
    let density: ESPNGlassDensity
    
    public init(
        cornerRadius: CGFloat = 16,
        density: ESPNGlassDensity = .medium,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.density = density
        self.content = content
    }
    
    public var body: some View {
        content()
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .espnGlassCard(cornerRadius: cornerRadius, density: density)
    }
}

// MARK: - Example Usage
/*
 // Basic glass effect
 Text("Hello ESPN")
     .padding()
     .espnGlassEffect(density: .medium)
 
 // Glass card
 VStack {
     Text("Live Score")
     Text("LAL 108 - GSW 102")
 }
 .padding()
 .espnGlassCard()
 
 // Glass button
 Button("Watch Now") { }
     .espnGlassButtonStyle()
 
 // Loading overlay
 ContentView()
     .espnGlassLoadingOverlay(isLoading: isLoading)
 
 // Live game indicator
 GameCard()
     .espnLiveGameGlass(isLive: true)
 
 // Native container (iOS 18+ only)
 if #available(iOS 18.0, *) {
     ESPNGlassContainer {
         Text("Premium Content")
     }
 }
 
 // Optimized glass (iOS 18+)
 if #available(iOS 18.0, *) {
     ComplexView()
         .espnOptimizedGlass()
 }
 */
