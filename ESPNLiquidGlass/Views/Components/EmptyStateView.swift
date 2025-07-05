import SwiftUI

struct EmptyStateView: View {
    // MARK: - Properties
    let icon: String
    let title: String
    let message: String
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
                .glassEffect(.regular, in: Circle())
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Previews
#Preview("No Articles") {
    EmptyStateView(
        icon: "newspaper",
        title: "No Articles",
        message: "Check back later for new content"
    )
}

#Preview("No Games") {
    EmptyStateView(
        icon: "sportscourt",
        title: "No Games Today",
        message: "No games scheduled for the selected date"
    )
}

#Preview("Dark Mode") {
    EmptyStateView(
        icon: "magnifyingglass",
        title: "No Results",
        message: "Try adjusting your filters"
    )
    .preferredColorScheme(.dark)
}