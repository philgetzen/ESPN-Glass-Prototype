import SwiftUI

struct ESPNPullToRefreshOverlay: ViewModifier {
    let isRefreshing: Bool
    let topOffset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    VStack {
                        if isRefreshing {
                            ESPNAnimatedLoadingIcon(size: 40)
                                .glassEffect(.regular, in: Circle())
                                .background(
                                    Circle()
                                        .fill(Color(UIColor.systemBackground))
                                        .frame(width: 60, height: 60)
                                        .shadow(radius: 4)
                                )
                                .scaleEffect(1.0)
                                .opacity(1.0)
                                .animation(.easeInOut(duration: 0.3), value: isRefreshing)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(y: topOffset)
                    .allowsHitTesting(false)
                }
            )
    }
}

extension View {
    func espnPullToRefreshOverlay(isRefreshing: Bool, topOffset: CGFloat = 50) -> some View {
        modifier(ESPNPullToRefreshOverlay(isRefreshing: isRefreshing, topOffset: topOffset))
    }
}

#Preview {
    ScrollView {
        VStack {
            ForEach(0..<20, id: \.self) { i in
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 60)
                    .padding(.horizontal)
            }
        }
    }
    .espnPullToRefreshOverlay(isRefreshing: false)
    .background(Color.black)
}
