import SwiftUI

struct ErrorView: View {
    // MARK: - Properties
    let error: String
    let retry: () async -> Void
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            // Error Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
                .glassEffect(.regular, in: Circle())
            
            // Error Message
            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(error)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Retry Button
            Button {
                Task {
                    await retry()
                }
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.system(size: 16, weight: .medium))
            }
            .buttonStyle(.borderedProminent)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Previews
#Preview("Network Error") {
    ErrorView(
        error: "Unable to connect to the server. Please check your internet connection.",
        retry: { print("Retry tapped") }
    )
}

#Preview("API Error") {
    ErrorView(
        error: "Failed to load articles. The server returned an invalid response.",
        retry: { print("Retry tapped") }
    )
}

#Preview("Dark Mode") {
    ErrorView(
        error: "Something went wrong. Please try again later.",
        retry: { print("Retry tapped") }
    )
    .preferredColorScheme(.dark)
}