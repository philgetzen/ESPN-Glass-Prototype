import SwiftUI

struct ESPNAnimatedLoadingIcon: View {
    let size: CGFloat
    @State private var currentFrame = 0
    @State private var timer: Timer?
    
    // ESPN loading animation frames (15 total)
    private let frameNames = [
        "ESPN_Loading_Frame_01", "ESPN_Loading_Frame_02", "ESPN_Loading_Frame_03", 
        "ESPN_Loading_Frame_04", "ESPN_Loading_Frame_05", "ESPN_Loading_Frame_06",
        "ESPN_Loading_Frame_07", "ESPN_Loading_Frame_08", "ESPN_Loading_Frame_09",
        "ESPN_Loading_Frame_10", "ESPN_Loading_Frame_11", "ESPN_Loading_Frame_12",
        "ESPN_Loading_Frame_13", "ESPN_Loading_Frame_14", "ESPN_Loading_Frame_15"
    ]
    
    init(size: CGFloat = 30) {
        self.size = size
    }
    
    var body: some View {
        Image(frameNames[currentFrame])
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .onAppear {
                startAnimation()
            }
            .onDisappear {
                stopAnimation()
            }
    }
    
    private func startAnimation() {
        // Stop any existing timer
        stopAnimation()
        
        // Start new timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { _ in
            Task { @MainActor in
                currentFrame = (currentFrame + 1) % frameNames.count
            }
        }
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    VStack(spacing: 20) {
        ESPNAnimatedLoadingIcon(size: 60)
        ESPNAnimatedLoadingIcon(size: 30)
    }
    .padding()
    .background(Color.black)
}