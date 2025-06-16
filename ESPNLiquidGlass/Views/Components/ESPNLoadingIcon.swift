import SwiftUI

struct ESPNLoadingIcon: View {
    let size: CGFloat
    @State private var isRotating = false
    
    init(size: CGFloat = 30) {
        self.size = size
    }
    
    var body: some View {
        Image("ESPN_Loading_Icon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(
                .linear(duration: 1.0)
                .repeatForever(autoreverses: false),
                value: isRotating
            )
            .onAppear {
                isRotating = true
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        ESPNLoadingIcon(size: 60)
        ESPNLoadingIcon(size: 30)
        ESPNLoadingIcon(size: 20)
    }
    .padding()
    .background(Color.black)
}