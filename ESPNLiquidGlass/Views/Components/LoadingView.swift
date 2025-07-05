import SwiftUI

struct LoadingView: View {
    // MARK: - Properties
    let message: String?
    
    // MARK: - Initialization
    init(_ message: String? = nil) {
        self.message = message
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            ESPNAnimatedLoadingIcon(size: 60)
                .glassEffect(.regular, in: Circle())
            
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Previews
#Preview("Loading with Message") {
    LoadingView("Loading articles...")
}

#Preview("Loading without Message") {
    LoadingView()
}

#Preview("Loading Dark Mode") {
    LoadingView("Fetching latest scores...")
        .preferredColorScheme(.dark)
}