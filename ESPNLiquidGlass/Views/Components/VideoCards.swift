import SwiftUI

// MARK: - Video Card Components with Performance Optimization and Proper Aspect Ratios

/// Large video card: 16:9 aspect ratio (320x180)
struct LargeVideoCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Image container with 16:9 aspect ratio
                CachedNonBlockingImage(url: video.thumbnailURL, contentMode: .fill)
                    .frame(width: 320, height: 180)
                    .clipped()
                    .cornerRadius(12)
                    .overlay(
                        // Live indicator in lower left
                        Group {
                            if video.isLive {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("LIVE")
                                            .font(.system(size: 10))
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.red)
                                            .cornerRadius(4)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                }
                                .padding(8)
                            }
                        }
                    )
                
                // Metadata
                if video.showMetadata && !video.tags.contains("tile-only") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(video.title)
                            .font(.system(size: 13))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        if hasVideoMetadata(video) {
                            Text(video.metadataText)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                        }
                        
                        if let duration = video.duration {
                            Text(formatDuration(duration))
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .frame(width: 320)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Medium video card: 16:9 aspect ratio (160x90)
struct MediumVideoCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Image container with 16:9 aspect ratio
                CachedNonBlockingImage(url: video.thumbnailURL, contentMode: .fill)
                    .frame(width: 160, height: 90)
                    .clipped()
                    .cornerRadius(8)
                    .overlay(
                        // Live indicator
                        Group {
                            if video.isLive {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("LIVE")
                                            .font(.system(size: 9))
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 2)
                                            .background(Color.red)
                                            .cornerRadius(3)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                }
                                .padding(6)
                            }
                        }
                    )
                
                // Metadata
                if video.showMetadata && !video.tags.contains("tile-only") {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(video.title)
                            .font(.system(size: 11))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        if hasVideoMetadata(video) {
                            Text(video.metadataText)
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                        }
                        
                        if let duration = video.duration {
                            Text(formatDuration(duration))
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .frame(width: 160)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Small video card: 16:9 aspect ratio (80x45)
struct SmallVideoCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                // Image container with 16:9 aspect ratio
                CachedNonBlockingImage(url: video.thumbnailURL, contentMode: .fill)
                    .frame(width: 80, height: 45)
                    .clipped()
                    .cornerRadius(6)
                    .overlay(
                        // Live indicator (smaller)
                        Group {
                            if video.isLive {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("LIVE")
                                            .font(.system(size: 8))
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 1)
                                            .background(Color.red)
                                            .cornerRadius(3)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                }
                                .padding(4)
                            }
                        }
                    )
                
                // Metadata (minimal for small cards)
                if video.showMetadata && !video.tags.contains("tile-only") {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(video.title)
                            .font(.system(size: 8))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        if hasVideoMetadata(video) {
                            Text(video.metadataText)
                                .font(.system(size: 7))
                                .foregroundColor(.gray)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
            }
            .frame(width: 80)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Poster video card: 2:3 aspect ratio (120x180) for movies
struct PosterVideoCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Image container with 2:3 aspect ratio
                CachedNonBlockingImage(url: video.thumbnailURL, contentMode: .fill)
                    .frame(width: 120, height: 180)
                    .clipped()
                    .cornerRadius(8)
                    .overlay(
                        // Live indicator
                        Group {
                            if video.isLive {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("LIVE")
                                            .font(.system(size: 9))
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 2)
                                            .background(Color.red)
                                            .cornerRadius(3)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                }
                                .padding(6)
                            }
                        }
                    )
                
                // Metadata
                if video.showMetadata && !video.tags.contains("tile-only") {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(video.title)
                            .font(.system(size: 11))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        if hasVideoMetadata(video) {
                            Text(video.metadataText)
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                        }
                        
                        if let duration = video.duration {
                            Text(formatDuration(duration))
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .frame(width: 120)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Show video card: 4:3 aspect ratio (160x120) for TV shows
struct ShowVideoCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Image container with 4:3 aspect ratio
                CachedNonBlockingImage(url: video.thumbnailURL, contentMode: .fill)
                    .frame(width: 160, height: 120)
                    .clipped()
                    .cornerRadius(8)
                    .overlay(
                        // Live indicator
                        Group {
                            if video.isLive {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("LIVE")
                                            .font(.system(size: 9))
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 2)
                                            .background(Color.red)
                                            .cornerRadius(3)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                }
                                .padding(6)
                            }
                        }
                    )
                
                // Metadata
                if video.showMetadata && !video.tags.contains("tile-only") {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(video.title)
                            .font(.system(size: 11))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        if hasVideoMetadata(video) {
                            Text(video.metadataText)
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                        }
                        
                        if let duration = video.duration {
                            Text(formatDuration(duration))
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .frame(width: 160)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Circle thumbnail card: 1:1 aspect ratio (100x100) for leagues/sports/conferences
struct CircleThumbnailCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)
                    
                    // Thumbnail - circular with 2/3 size
                    if let thumbnailURL = video.thumbnailURL {
                        CachedNonBlockingImage(url: request1x1Asset(from: thumbnailURL), contentMode: .fill)
                            .frame(width: 66, height: 66)
                            .clipShape(Circle())
                    }
                }
                
                Text(video.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 100)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Square thumbnail card: 1:1 aspect ratio (100x100) for networks/channels
struct SquareThumbnailCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)
                    
                    // Thumbnail - square with 2/3 size
                    if let thumbnailURL = video.thumbnailURL {
                        CachedNonBlockingImage(url: request1x1Asset(from: thumbnailURL), contentMode: .fill)
                            .frame(width: 66, height: 66)
                            .clipped()
                            .cornerRadius(8)
                    }
                }
                
                Text(video.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 100)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Hero video card component
struct HeroVideoCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background with gradient
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .aspectRatio(16/9, contentMode: .fit)
                
                // Thumbnail if available
                if let thumbnailURL = video.thumbnailURL {
                    CachedNonBlockingImage(url: thumbnailURL, contentMode: .fill)
                        .aspectRatio(16/9, contentMode: .fit)
                        .clipped()
                }
                
                // Content overlay
                VStack {
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                if video.isLive {
                                    Text("LIVE")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red)
                                        .cornerRadius(4)
                                }
                                
                                if let league = video.league {
                                    Text(league)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue)
                                        .cornerRadius(4)
                                }
                            }
                            
                            Text(video.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .lineLimit(2)
                            
                            if let description = video.description {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.black.opacity(0.9), Color.clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                }
            }
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Inline header card component
struct InlineHeaderCard: View {
    let category: VideoCategory
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section with 58:13 aspect ratio for inline headers
            Button(action: onTap) {
                CachedNonBlockingImage(url: video.thumbnailURL, contentMode: .fill)
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
            .buttonStyle(PlainButtonStyle())
            
            // Bottom section with content
            VStack(alignment: .leading, spacing: 16) {
                // Main content section
                VStack(alignment: .leading, spacing: 12) {
                    Text(category.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    if !category.description.isEmpty && category.description != category.name {
                        Text(category.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                    }
                }
                
                // Status button
                Button(action: onTap) {
                    Text(video.isLive ? "LIVE" : "Upcoming")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(video.isLive ? Color.red : Color.blue.opacity(0.8))
                        .cornerRadius(25)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Metadata section
                HStack {
                    Text("ESPN")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let league = video.league {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.6))
                        Text(league.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    
                    if let network = video.network {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.6))
                        Text(network)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                    
                    let dateText = formatVideoDate(video.publishedDate)
                    if !dateText.contains("0s") {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.6))
                        Text(dateText)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if let duration = video.duration {
                        Text(formatDuration(duration))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .espnGlassCard(cornerRadius: 12, density: ESPNGlassDensity.light)
        .padding(.horizontal)
        .preferredColorScheme(.dark)
    }
}

/// Explore tile card component (text-based)
struct ExploreTileCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(video.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                )
                .frame(height: 50)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Helper Functions

private func request1x1Asset(from originalURL: String) -> String {
    var optimizedURL = originalURL
    
    if originalURL.contains("espncdn.com") {
        var urlComponents = URLComponents(string: originalURL)
        var queryItems = urlComponents?.queryItems ?? []
        
        // Remove existing size params
        queryItems.removeAll { item in
            ["w", "width", "h", "height"].contains(item.name.lowercased())
        }
        
        // Add square sizing
        queryItems.append(URLQueryItem(name: "w", value: "100"))
        queryItems.append(URLQueryItem(name: "h", value: "100"))
        queryItems.append(URLQueryItem(name: "f", value: "jpg"))
        queryItems.append(URLQueryItem(name: "crop", value: "1"))
        
        urlComponents?.queryItems = queryItems
        optimizedURL = urlComponents?.url?.absoluteString ?? originalURL
    }
    
    return optimizedURL
}

private func formatDuration(_ duration: TimeInterval) -> String {
    let minutes = Int(duration) / 60
    let seconds = Int(duration) % 60
    return String(format: "%d:%02d", minutes, seconds)
}

private func formatVideoDate(_ date: Date) -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter.localizedString(for: date, relativeTo: Date())
}

private func hasVideoMetadata(_ video: VideoItem) -> Bool {
    return video.network != nil || video.reAir != nil || video.eventName != nil
}

// Legacy compatibility
struct VideoThumbnailCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        MediumVideoCard(video: video, onTap: onTap)
    }
}
