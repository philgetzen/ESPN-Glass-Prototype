import SwiftUI

struct ESPNRefreshIndicator: View {
    @State private var isVisible = false
    let isRefreshing: Bool
    
    var body: some View {
        VStack {
            if isRefreshing {
                ESPNAnimatedLoadingIcon(size: 40)
                    .glowEffect(
                        color: .red,
                        radius: 6
                    )
                    .opacity(isVisible ? 1 : 0)
                    .scaleEffect(isVisible ? 1 : 0.8)
                    .animation(.easeInOut(duration: 0.3), value: isVisible)
                    .onAppear {
                        isVisible = true
                    }
                    .onDisappear {
                        isVisible = false
                    }
            }
        }
        .frame(height: isRefreshing ? 60 : 0)
        .clipped()
    }
}

#Preview {
    VStack(spacing: 40) {
        ESPNRefreshIndicator(isRefreshing: true)
        ESPNRefreshIndicator(isRefreshing: false)
    }
    .padding()
    .background(Color.black)
}