import SwiftUI

struct ESPNRefreshOverlay: ViewModifier {
    let isRefreshing: Bool
    let topOffset: CGFloat // Custom offset for different view layouts
    
    func body(content: Content) -> some View {
        content
            .overlay(
                // Position our ESPN icon where the native refresh indicator appears
                VStack {
                    if isRefreshing {
                        ESPNAnimatedLoadingIcon(size: 30)
                            .onAppear {
                                print("🎯 ESPN Refresh Overlay: Icon appeared")
                            }
                            .glowEffect(
                                color: .red,
                                radius: 6,
                                intensity: .medium,
                                pulsation: .gentle
                            )
                            .background(
                                // Larger background to hide system indicator
                                Circle()
                                    .fill(Color(UIColor.systemBackground))
                                    .frame(width: 50, height: 50)
                            )
                            .transition(.scale.combined(with: .opacity))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(y: topOffset) // Fixed position, always visible
                .allowsHitTesting(false) // Don't interfere with scrolling
            )
    }
}

extension View {
    func espnRefreshOverlay(isRefreshing: Bool, topOffset: CGFloat = -10) -> some View {
        modifier(ESPNRefreshOverlay(isRefreshing: isRefreshing, topOffset: topOffset))
    }
}

#Preview {
    ScrollView {
        VStack {
            ForEach(0..<10, id: \.self) { i in
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 60)
                    .padding(.horizontal)
            }
        }
    }
    .espnRefreshOverlay(isRefreshing: true)
    .background(Color.black)
}