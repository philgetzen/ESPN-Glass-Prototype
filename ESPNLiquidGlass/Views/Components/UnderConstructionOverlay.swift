import SwiftUI

struct UnderConstructionOverlay: View {
    @State private var isVisible = false
    @State private var pulseAnimation = false
    
    let onDismiss: (() -> Void)?
    
    init(onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            // iOS 26 Native Glass Background
            if #available(iOS 26.0, *) {
                Rectangle()
                    .fill(.clear)
                    .background(.regularMaterial)
                    .glassEffect(.regular, in: Rectangle())
                    .ignoresSafeArea()
            } else {
                // Fallback for iOS 18-25
                Rectangle()
                    .fill(.regularMaterial)
                    .ignoresSafeArea()
            }
            
            // Content
            VStack(spacing: 24) {
                // Construction Icon with Pulse Animation
                ZStack {
                    Circle()
                        .fill(.orange.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        .opacity(pulseAnimation ? 0.8 : 1.0)
                    
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(pulseAnimation ? 15 : -15))
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        pulseAnimation = true
                    }
                }
                
                // Text Content
                VStack(spacing: 12) {
                    Text("Under Construction")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("This section is being built with cutting-edge iOS 26 glass effects")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Text("Coming Soon")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background {
                            if #available(iOS 26.0, *) {
                                Capsule()
                                    .fill(.clear)
                                    .background(.ultraThinMaterial)
                                    .glassEffect(.regular, in: Capsule())
                            } else {
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            }
                        }
                }
                
                // Optional Dismiss Button (for development/testing)
                if let onDismiss = onDismiss {
                    Button(action: onDismiss) {
                        Text("Dismiss (Dev Mode)")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background {
                                if #available(iOS 26.0, *) {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.clear)
                                        .background(.ultraThinMaterial)
                                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
                                } else {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                }
                            }
                    }
                    .padding(.top, 20)
                }
            }
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Previews
#Preview("Under Construction") {
    UnderConstructionOverlay()
        .preferredColorScheme(.dark)
}

#Preview("With Dismiss Button") {
    UnderConstructionOverlay(onDismiss: {
        print("Dismissed construction overlay")
    })
        .preferredColorScheme(.light)
}

#Preview("Over Content") {
    ZStack {
        // Simulated background content
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<10) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.blue.opacity(0.3))
                        .frame(height: 100)
                        .overlay(
                            Text("Content \(index + 1)")
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                }
            }
            .padding()
        }
        .background(.regularMaterial)
        
        // Overlay
        UnderConstructionOverlay(onDismiss: {})
    }
    .preferredColorScheme(.dark)
}