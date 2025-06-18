import SwiftUI

// MARK: - Non-Blocking Image Component with Caching
public struct CachedNonBlockingImage: View {
    let url: String?
    let contentMode: ContentMode
    @State private var image: UIImage?
    @State private var loadTask: Task<Void, Never>?
    @State private var isLoading = true
    
    // Simple in-memory cache
    private static var imageCache = NSCache<NSString, UIImage>()
    
    public init(url: String?, contentMode: ContentMode = .fill) {
        self.url = url
        self.contentMode = contentMode
    }
    
    public var body: some View {
        ZStack {
            // Always show placeholder first
            Rectangle()
                .fill(LinearGradient(
                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            // Show loading indicator while loading
            if isLoading && image == nil {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
            }
            
            // Show image when loaded
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(.opacity)
            }
        }
        .task(id: url) {
            await loadImage()
        }
        .onDisappear {
            loadTask?.cancel()
            loadTask = nil
        }
    }
    
    private func loadImage() async {
        guard let urlString = url,
              let imageURL = URL(string: urlString) else {
            await MainActor.run {
                isLoading = false
            }
            return
        }
        
        // Check cache first
        if let cachedImage = Self.imageCache.object(forKey: urlString as NSString) {
            await MainActor.run {
                self.image = cachedImage
                self.isLoading = false
            }
            return
        }
        
        loadTask?.cancel()
        
        loadTask = Task {
            do {
                // Use background queue for image loading
                let (data, _) = try await URLSession.shared.data(from: imageURL)
                
                guard !Task.isCancelled else { return }
                
                // Decode image on background queue
                if let decodedImage = await decodeImage(data: data) {
                    // Cache the image
                    Self.imageCache.setObject(decodedImage, forKey: urlString as NSString)
                    
                    await MainActor.run {
                        withAnimation(.easeIn(duration: 0.2)) {
                            self.image = decodedImage
                            self.isLoading = false
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func decodeImage(data: Data) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let image = UIImage(data: data)
                continuation.resume(returning: image)
            }
        }
    }
}
