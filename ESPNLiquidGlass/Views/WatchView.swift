import SwiftUI

struct WatchView: View {
    @State private var viewState = WatchViewState.loading
    @State private var selectedVideoItem: VideoItem?
    @State private var showSettings = false
    @Binding var colorScheme: ColorScheme?
    
    private let apiService = ESPNAPIService.shared
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewState {
                case .loading:
                    LoadingView("Loading videos...")
                    
                case .loaded(let categories):
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            // Video Categories
                            ForEach(categories) { category in
                                VideoCategorySection(category: category) { video in
                                    if video.videoURL != nil {
                                        selectedVideoItem = video
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    
                case .error(let errorMessage):
                    ErrorView(error: errorMessage, retry: loadVideoContent)
                    
                case .empty:
                    EmptyStateView(
                        icon: "play.rectangle",
                        title: "No Videos Available",
                        message: "Check back later for new video content"
                    )
                }
            }
            .background(
                Color.black
                    .overlay(
                        Image("background")
                            .resizable()
                            .scaledToFill()
                            .opacity(0.8)
                    )
                    .ignoresSafeArea(.all)
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .espnToolbar(
                isDarkMode: true,
                onSettingsTap: { showSettings = true }
            )
            .sheet(isPresented: $showSettings) {
                SettingsView(colorScheme: $colorScheme)
                    .preferredColorScheme(colorScheme)
            }
            .sheet(item: $selectedVideoItem) { video in
                if let videoURL = video.videoURL, let url = URL(string: videoURL) {
                    VideoPlayerView(videoURL: url, article: Article(from: video))
                        .preferredColorScheme(.dark)
                }
            }
        }
        .refreshableWithHaptics {
            await loadVideoContent()
        }
        .preferredColorScheme(.dark)
        .task {
            await loadVideoContent()
        }
    }
    
    private func loadVideoContent() async {
        await MainActor.run {
            if case .loaded(_) = viewState {
                // Keep existing content during refresh
            } else {
                viewState = .loading
            }
        }
        
        do {
            print("🎬 Starting video content fetch at \(Date())...")
            let categories = try await apiService.fetchVideoContent()
            
            await MainActor.run {
                if categories.isEmpty {
                    viewState = .empty
                } else {
                    viewState = .loaded(categories)
                    print("🎬 Loaded \(categories.count) video categories at \(Date())")
                    
                    // Debug: Check data freshness for each category
                    for (index, category) in categories.enumerated() {
                        let liveCount = category.videos.filter { $0.isLive }.count
                        let totalCount = category.videos.count
                        let mostRecentDate = category.videos.map { $0.publishedDate }.max() ?? Date.distantPast
                        let timeSinceLatest = Date().timeIntervalSince(mostRecentDate)
                        
                        print("📊 Category \(index): '\(category.name)' - \(totalCount) videos (\(liveCount) live) - Latest content: \(timeSinceLatest/3600)h ago")
                        
                        if index == 3 {
                            print("🔍 Also Live row (bucket 3) - Priority: \(category.priority), Tags: \(category.tags)")
                        }
                    }
                }
            }
        } catch {
            print("❌ Error loading video content: \(error)")
            await MainActor.run {
                viewState = .error(error.localizedDescription)
            }
        }
    }
    
    private func isHeroBucket(_ name: String) -> Bool {
        // This function is legacy - hero detection is now done via tags in VideoCategorySection
        return false
    }
}

// MARK: - Hero Video Card Component
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
                if let thumbnailURL = video.thumbnailURL, let url = URL(string: thumbnailURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    }
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
            .cornerRadius(12) // Added corner radius
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Video Category Section Component
struct VideoCategorySection: View {
    let category: VideoCategory
    let onVideoTap: (VideoItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Handle different category types based on parser tags
            if hasExploreTag {
                exploreTileView
            } else if hasInlineHeaderTag && category.videos.count == 1 {
                heroTileView
            } else {
                standardCategoryView
            }
        }
    }
    
    private var exploreTileView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category header (if should show title)
            if shouldShowTitle {
                HStack {
                    Text(category.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            // Text-based explore tiles
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(category.videos) { video in
                        ExploreTileCard(video: video) {
                            onVideoTap(video)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var heroTileView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category header (if should show title)
            if shouldShowTitle {
                HStack {
                    Text(category.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            // Large hero tile
            if let video = category.videos.first {
                Button(action: { onVideoTap(video) }) {
                    ZStack {
                        // Thumbnail with fixed aspect ratio
                        Group {
                            if let thumbnailURL = video.thumbnailURL, let url = URL(string: thumbnailURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle()
                                        .fill(LinearGradient(
                                            colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .overlay(
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        )
                                }
                            } else {
                                Rectangle()
                                    .fill(LinearGradient(
                                        colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            }
                        }
                        .aspectRatio(16/9, contentMode: .fit)
                        .clipped()
                        
                        // Live badge overlay (lower left)
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
                        
                        // Content overlay
                        VStack {
                            Spacer()
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(video.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                    
                                    if let description = video.description {
                                        Text(description)
                                            .font(.subheadline)
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
                    .padding(.horizontal)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var standardCategoryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category header (if should show title)
            if shouldShowTitle {
                HStack {
                    Text(category.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("See All")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 12) {
                    ForEach(sortedVideos()) { video in
                        videoCardForContent(video: video, onTap: { onVideoTap(video) })
                    }
                }
                .padding(.horizontal)
                .padding(.trailing, hasLargeCards ? 20 : 0) // Extra padding for large cards
            }
        }
    }
    
    // MARK: - Tag Detection Helpers
    
    private var hasExploreTag: Bool {
        category.tags.contains("explore_tile") || category.tags.contains("explore")
    }
    
    private var hasInlineHeaderTag: Bool {
        category.tags.contains("inline-header")
    }
    
    private var hasBreakoutRowTag: Bool {
        // Only apply BREAKOUT_ROW_LEAGUES logic to actual league/sport/conference categories
        // Not to Featured or Also Live rows
        let isSpecialContentRow = isFeaturedRow || isAlsoLiveRow
        
        return category.tags.contains("BREAKOUT_ROW_LEAGUES") && 
               !isSpecialContentRow &&
               (isLeagueSportOrConference(category.name) || category.name.lowercased().contains("league"))
    }
    
    private var isFeaturedRow: Bool {
        return category.name.lowercased().contains("featured")
    }
    
    private var isAlsoLiveRow: Bool {
        // Also Live row is specifically bucket ID 3
        return category.priority == 3
    }
    
    private var hasTileOnlyTag: Bool {
        category.tags.contains("tile-only")
    }
    
    private var hasNoTitleTag: Bool {
        category.tags.contains("noTitle")
    }
    
    private var shouldShowTitle: Bool {
        // Show title if showTitle is true AND it's not marked as noTitle
        // For explore rows, NEVER show title (they should be title-less)
        if hasExploreTag {
            return false // Never show title for explore rows
        }
        return category.showTitle && !hasNoTitleTag
    }
    
    private var hasLargeCards: Bool {
        // Check if this category contains large cards that need extra padding
        return category.videos.contains { video in
            video.size?.lowercased() == "lg" || video.size?.lowercased() == "large"
        }
    }
    
    private func isHeroBucket(_ name: String) -> Bool {
        return hasInlineHeaderTag
    }
    
    private func isLeagueSportOrConference(_ name: String) -> Bool {
        let lowerName = name.lowercased()
        return lowerName == "leagues" || lowerName == "sports" || lowerName == "conferences"
    }
    
    private func isNetwork(_ name: String) -> Bool {
        let lowerName = name.lowercased()
        return lowerName == "channels" || lowerName.contains("network")
    }
    
    @ViewBuilder
    private func videoCardForContent(video: VideoItem, onTap: @escaping () -> Void) -> some View {
        // Check video-specific tags and types first
        if video.tags.contains("rowCap") || shouldUseSquareForFirstItem(video) {
            SquareThumbnailCard(video: video, onTap: onTap)
        } else if shouldUseCircleLayout(for: video) {
            CircleThumbnailCard(video: video, onTap: onTap)
        } else if shouldUseSquareLayout(for: video) {
            SquareThumbnailCard(video: video, onTap: onTap)
        } else {
            // Use size-based rendering as fallback
            videoCardForSize(video: video, onTap: onTap)
        }
    }
    
    private func shouldUseSquareForFirstItem(_ video: VideoItem) -> Bool {
        // Only use square layout for first item if it's a true BREAKOUT_ROW_LEAGUES category
        // AND this is the first video in the sorted list
        return hasBreakoutRowTag && video == sortedVideos().first
    }
    
    private func shouldUseCircleLayout(for video: VideoItem) -> Bool {
        // Circle layout for leagues, sports, conferences, or specific types
        return isLeagueSportOrConference(category.name) || 
               video.type?.lowercased() == "league" ||
               video.type?.lowercased() == "sport" ||
               video.type?.lowercased() == "conference"
    }
    
    private func shouldUseSquareLayout(for video: VideoItem) -> Bool {
        // Square layout for networks, channels, or specific types
        return isNetwork(category.name) ||
               video.type?.lowercased() == "network" ||
               video.type?.lowercased() == "channel" ||
               video.tags.contains("square")
    }
    
    @ViewBuilder
    private func videoCardForSize(video: VideoItem, onTap: @escaping () -> Void) -> some View {
        switch video.size?.lowercased() {
        case "lg", "large":
            LargeVideoCard(video: video, onTap: onTap)
        case "sm", "small":
            SmallVideoCard(video: video, onTap: onTap)
        case "md", "medium", nil: // Default to medium if not specified
            MediumVideoCard(video: video, onTap: onTap)
        default:
            MediumVideoCard(video: video, onTap: onTap) // Fallback for unknown sizes
        }
    }
    
    
    private func sortedVideos() -> [VideoItem] {
        // Use the original order from the Watch API - ESPN determines the correct ordering
        return category.videos
    }
    
}


// MARK: - Size-Based Video Card Components

/// Large video card: 1 card + 1/5 peek of second (approximately 320px + 64px peek)
struct LargeVideoCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Image container with fixed aspect ratio
                Group {
                    if let thumbnailURL = video.thumbnailURL, let url = URL(string: thumbnailURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(LinearGradient(
                                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                )
                        }
                    } else {
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    }
                }
                .frame(width: 320, height: 180) // Fixed 16:9 aspect ratio
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
                
                // Show metadata only if enabled (respects parser showMetadata and tile-only tags)
                if video.showMetadata && !video.tags.contains("tile-only") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(video.title)
                            .font(.system(size: 13))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(width: 320, alignment: .leading)
                        
                        // Video metadata: Network, Re-Air (if applicable), Event Name
                        VStack(alignment: .leading, spacing: 2) {
                            // Display metadata with proper wrapping
                            if hasVideoMetadata(video) {
                                Text(buildMetadataText(for: video))
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                    .frame(width: 320, alignment: .leading)
                            }
                            
                            // Duration on separate line
                            if let duration = video.duration {
                                Text(formatDuration(duration))
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .frame(width: 320)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func hasVideoMetadata(_ video: VideoItem) -> Bool {
        return video.network != nil || video.reAir != nil || video.eventName != nil
    }
    
    private func buildMetadataText(for video: VideoItem) -> String {
        var components: [String] = []
        
        if let network = video.network {
            components.append(network)
        }
        
        if let reAir = video.reAir {
            components.append(reAir)
        }
        
        if let eventName = video.eventName {
            components.append(eventName)
        }
        
        return components.joined(separator: " • ")
    }
    
}

/// Medium video card: 2 cards + peek of 3rd (approximately 160px each + 32px peek)
struct MediumVideoCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Image container with fixed aspect ratio
                Group {
                    if let thumbnailURL = video.thumbnailURL, let url = URL(string: thumbnailURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(LinearGradient(
                                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                    } else {
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    }
                }
                .frame(width: 160, height: 90) // Fixed 16:9 aspect ratio
                .clipped()
                .cornerRadius(8)
                .overlay(
                    // Live indicator in lower left
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
                
                // Show metadata only if enabled (respects parser showMetadata and tile-only tags)
                if video.showMetadata && !video.tags.contains("tile-only") {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(video.title)
                            .font(.system(size: 11))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(width: 160, alignment: .leading)
                        
                        // Video metadata: Network, Re-Air (if applicable), Event Name
                        VStack(alignment: .leading, spacing: 2) {
                            // Display metadata with proper wrapping
                            if hasVideoMetadata(video) {
                                Text(buildMetadataText(for: video))
                                    .font(.system(size: 9))
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                    .frame(width: 160, alignment: .leading)
                            }
                            
                            // Duration on separate line
                            if let duration = video.duration {
                                Text(formatDuration(duration))
                                    .font(.system(size: 9))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .frame(width: 160)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func hasVideoMetadata(_ video: VideoItem) -> Bool {
        return video.network != nil || video.reAir != nil || video.eventName != nil
    }
    
    private func buildMetadataText(for video: VideoItem) -> String {
        var components: [String] = []
        
        if let network = video.network {
            components.append(network)
        }
        
        if let reAir = video.reAir {
            components.append(reAir)
        }
        
        if let eventName = video.eventName {
            components.append(eventName)
        }
        
        return components.joined(separator: " • ")
    }
    
}

/// Small video card: 4 cards + peek of 5th (approximately 80px each + 16px peek)
struct SmallVideoCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                // Image container with fixed aspect ratio
                Group {
                    if let thumbnailURL = video.thumbnailURL, let url = URL(string: thumbnailURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(LinearGradient(
                                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                    } else {
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    }
                }
                .frame(width: 80, height: 45) // Fixed 16:9 aspect ratio
                .clipped()
                .cornerRadius(6)
                .overlay(
                    // Live indicator in lower left (smaller for small cards)
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
                
                // Show metadata only if enabled (respects parser showMetadata and tile-only tags)
                if video.showMetadata && !video.tags.contains("tile-only") {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(video.title)
                            .font(.system(size: 8))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(width: 80, alignment: .leading)
                        
                        // Minimal metadata for small cards
                        if hasVideoMetadata(video) {
                            Text(buildMetadataText(for: video))
                                .font(.system(size: 7))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .frame(width: 80, alignment: .leading)
                        }
                    }
                }
            }
            .frame(width: 80)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func hasVideoMetadata(_ video: VideoItem) -> Bool {
        return video.network != nil || video.reAir != nil || video.eventName != nil
    }
    
    private func buildMetadataText(for video: VideoItem) -> String {
        var components: [String] = []
        
        if let network = video.network {
            components.append(network)
        }
        
        if let reAir = video.reAir {
            components.append(reAir)
        }
        
        if let eventName = video.eventName {
            components.append(eventName)
        }
        
        return components.joined(separator: " • ")
    }
}

// Legacy component for backward compatibility
struct VideoThumbnailCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        MediumVideoCard(video: video, onTap: onTap)
    }
}

// MARK: - Circle Thumbnail Card Component (for Leagues/Sports/Conferences)
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
                    
                    // Thumbnail if available - request 1x1 assets and size to 2/3 of container
                    if let thumbnailURL = video.thumbnailURL, let url = URL(string: request1x1Asset(from: thumbnailURL)) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                        .frame(width: 66, height: 66) // 2/3 of 100px container
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

// MARK: - Square Thumbnail Card Component (for Networks)
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
                    
                    // Thumbnail if available - request 1x1 assets and size to 2/3 of container
                    if let thumbnailURL = video.thumbnailURL, let url = URL(string: request1x1Asset(from: thumbnailURL)) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(
                                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                        .frame(width: 66, height: 66) // 2/3 of 100px container
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

// MARK: - Explore Tile Card Component (for text-based explore tiles)
struct ExploreTileCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(video.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1) // Single line only
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
                .frame(height: 50) // Fixed height
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Helper Functions
private func request1x1Asset(from originalURL: String) -> String {
    // ESPN CDN URL optimization for 1x1 (square) assets
    var optimizedURL = originalURL
    
    if originalURL.contains("a.espncdn.com") || originalURL.contains("espncdn.com") {
        var urlComponents = URLComponents(string: originalURL)
        
        // Create or update query items for 1x1 sizing
        var queryItems = urlComponents?.queryItems ?? []
        
        // Remove existing width/height params
        queryItems.removeAll { item in
            ["w", "width", "h", "height"].contains(item.name.lowercased())
        }
        
        // Add 1x1 sizing (square)
        queryItems.append(URLQueryItem(name: "w", value: "100"))
        queryItems.append(URLQueryItem(name: "h", value: "100"))
        queryItems.append(URLQueryItem(name: "f", value: "jpg"))
        queryItems.append(URLQueryItem(name: "crop", value: "1")) // Crop to fit exact dimensions
        
        urlComponents?.queryItems = queryItems
        optimizedURL = urlComponents?.url?.absoluteString ?? originalURL
    }
    
    return optimizedURL
}

// MARK: - Extensions for Article compatibility
extension Article {
    init(from videoItem: VideoItem) {
        self.init(
            title: videoItem.title,
            subtitle: videoItem.description,
            author: videoItem.league ?? "ESPN",
            publishedDate: videoItem.publishedDate,
            imageURL: videoItem.thumbnailURL,
            content: videoItem.description ?? "",
            type: .video,
            readTime: Int(videoItem.duration ?? 0) / 60,
            sport: Sport.allCases.first { $0.rawValue.lowercased() == videoItem.sport?.lowercased() },
            relatedTeams: [],
            likes: 0,
            comments: 0,
            isPremium: false,
            articleURL: nil,
            videoURL: videoItem.videoURL
        )
    }
}

#Preview {
    WatchView(colorScheme: .constant(.dark))
}

#Preview("Dark Mode") {
    WatchView(colorScheme: .constant(.dark))
        .preferredColorScheme(.dark)
}
