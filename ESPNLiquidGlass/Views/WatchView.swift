import SwiftUI

struct WatchView: View {
    @State private var viewState = WatchViewState.loading
    @State private var selectedVideoItem: VideoItem?
    @State private var showSettings = false
    @State private var isRefreshing = false
    @State private var lastRefreshTime: Date?
    @State private var showESPNAppAlert = false
    @State private var showPlaybackErrorAlert = false
    @State private var playbackErrorMessage = ""
    @State private var hasShownESPNAppAlertThisSession = false
    @State private var espnAppVideoItem: VideoItem?
    @State private var isResolvingPlaybackURL = false
    @Binding var colorScheme: ColorScheme?
    
    private let apiService = ESPNAPIService.shared
    private let refreshInterval: TimeInterval = 300 // 5 minutes
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewState {
                case .loading:
                    LoadingView("Loading videos...")
                        .onAppear {
                            // Ensure refresh overlay is off during initial loading
                            isRefreshing = false
                        }
                    
                case .loaded(let categories):
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            // Video Categories
                            ForEach(categories) { category in
                                VideoCategorySection(category: category) { video in
                                    handleVideoTap(video)
                                }
                                .preferredColorScheme(.dark)
                            }
                        }
                        .padding(.vertical)
                    }
                    
                case .error(let errorMessage):
                    ErrorView(error: errorMessage, retry: { await loadVideoContentIfNeeded(force: true) })
                    
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
            .adaptiveBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .espnToolbar(
                isDarkMode: true,
                onSettingsTap: { showSettings = true }
            )
            .id("watch-toolbar")
            .sheet(isPresented: $showSettings) {
                SettingsView(colorScheme: $colorScheme)
                    .preferredColorScheme(colorScheme)
            }
            .sheet(item: $selectedVideoItem) { video in
                if let streamingURL = video.streamingURL, 
                   !streamingURL.isEmpty,
                   let url = URL(string: streamingURL) {
                    VideoPlayerView(videoURL: url, article: Article(from: video))
                        .preferredColorScheme(.dark)
                        .onDisappear {
                            // Clear selected video when sheet disappears to prevent memory issues
                            selectedVideoItem = nil
                        }
                } else {
                    // Fallback view if URL is invalid
                    VStack {
                        Text("Video Unavailable")
                            .font(.headline)
                        Text("This video cannot be played at this time.")
                            .foregroundColor(.secondary)
                        Button("Close") {
                            selectedVideoItem = nil
                        }
                        .padding()
                    }
                    .preferredColorScheme(.dark)
                }
            }
            .alert("ESPN App Required", isPresented: $showESPNAppAlert) {
                Button("Open ESPN App") {
                    openESPNApp(for: espnAppVideoItem)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("ESPN Watch content is best experienced in the ESPN app. You'll be redirected there for playback.")
            }
            .alert("Playback Error", isPresented: $showPlaybackErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Content is not playable at this time.\n\nDebug: \(playbackErrorMessage)")
            }
        }
        .refreshableWithHaptics {
            await MainActor.run { isRefreshing = true }
            // Add delay to ensure refresh indicator shows
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            await loadVideoContentIfNeeded(force: true)
            // Keep indicator visible longer after completion
            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
            await MainActor.run { isRefreshing = false }
        }
        .preferredColorScheme(.dark)
        .task {
            await loadVideoContentIfNeeded(force: false)
        }
        .espnPullToRefreshOverlay(isRefreshing: isRefreshing, topOffset: 120)
    }
    
    private func loadVideoContentIfNeeded(force: Bool) async {
        // Check if we need to refresh
        let needsRefresh = force || shouldRefresh()
        
        if !needsRefresh {
            return
        }
        
        
        await MainActor.run {
            if case .loaded(_) = viewState {
                // Keep existing content during refresh
            } else {
                viewState = .loading
            }
        }
        
        do {
            let categories = try await apiService.fetchVideoContent()
            
            await MainActor.run {
                if categories.isEmpty {
                    viewState = .empty
                } else {
                    viewState = .loaded(categories)
                    lastRefreshTime = Date()
                }
            }
        } catch {
            await MainActor.run {
                // Only show error if we don't have cached content
                if case .loading = viewState {
                    viewState = .error(error.localizedDescription)
                } else {
                }
            }
        }
    }
    
    private func shouldRefresh() -> Bool {
        guard let lastRefresh = lastRefreshTime else {
            return true // First time loading
        }
        
        let timeSinceRefresh = Date().timeIntervalSince(lastRefresh)
        return timeSinceRefresh >= refreshInterval
    }
    
    private func isHeroBucket(_ name: String) -> Bool {
        // This function is legacy - hero detection is now done via tags in VideoCategorySection
        return false
    }
    
    // MARK: - Video Playback Handling
    
    private func handleVideoTap(_ video: VideoItem) {
        
        // Check if this video requires ESPN app authentication
        if video.requiresESPNApp {
            
            // Show alert only once per session for authenticated content
            if !hasShownESPNAppAlertThisSession {
                espnAppVideoItem = video
                showESPNAppAlert = true
                hasShownESPNAppAlertThisSession = true
            } else {
                openESPNApp(for: video)
            }
        } else {
            // For clips and unrestricted content, try direct playback
            
            if let streamingURL = video.streamingURL, !streamingURL.isEmpty {
                // Check if this is a play API URL that needs to be resolved
                if streamingURL.contains("/playback/video/") {
                    // Prevent multiple simultaneous resolve operations
                    guard !isResolvingPlaybackURL else {
                        return
                    }
                    
                    isResolvingPlaybackURL = true
                    Task {
                        await resolvePlaybackURL(for: video, apiURL: streamingURL)
                        await MainActor.run {
                            isResolvingPlaybackURL = false
                        }
                    }
                } else {
                    selectedVideoItem = video
                }
            } else {
                // Don't show alert for missing URLs on browse items (categories/leagues/etc)
                // These are typically navigation items, not playable content
                if !video.tags.contains("tile-only") {
                    playbackErrorMessage = "This content is not available for direct playback"
                    showPlaybackErrorAlert = true
                }
            }
        }
    }
    
    private func openESPNApp(for video: VideoItem?) {
        guard let video = video else {
            playbackErrorMessage = "No video available for deep linking"
            showPlaybackErrorAlert = true
            return
        }
        
        // Use the actual appPlay URL from ESPN API instead of constructing manually
        guard let appPlayURLString = video.appPlayURL else {
            playbackErrorMessage = "No ESPN app deep link URL available"
            showPlaybackErrorAlert = true
            return
        }
        
        
        if let espnURL = URL(string: appPlayURLString) {
            if UIApplication.shared.canOpenURL(espnURL) {
                UIApplication.shared.open(espnURL)
            } else {
                // ESPN app not installed, try web URL fallback
                if let webURL = video.streamingURL, let url = URL(string: webURL) {
                    UIApplication.shared.open(url)
                } else {
                    // No web URL available, redirect to App Store
                    if let appStoreURL = URL(string: "https://apps.apple.com/app/espn-live-sports-scores/id317469184") {
                        UIApplication.shared.open(appStoreURL)
                    }
                }
            }
        }
    }
    
    // MARK: - Playback URL Resolution
    
    private func resolvePlaybackURL(for video: VideoItem, apiURL: String) async {
        do {
            
            // Use ESPNAPIService to resolve the URL with proper timeout and TLS handling
            let videoHref = try await apiService.resolvePlaybackURL(from: apiURL)
            
            // Create resolved video item off the main thread to avoid blocking
            let resolvedVideo = VideoItem(
                title: video.title,
                description: video.description,
                thumbnailURL: video.thumbnailURL,
                videoURL: videoHref, // Use the resolved URL
                duration: video.duration,
                publishedDate: video.publishedDate,
                sport: video.sport,
                league: video.league,
                isLive: video.isLive,
                viewCount: video.viewCount,
                tags: video.tags,
                autoplay: video.autoplay,
                showMetadata: video.showMetadata,
                size: video.size,
                type: video.type,
                network: video.network,
                reAir: video.reAir,
                eventName: video.eventName,
                ratio: video.ratio,
                authType: video.authType,
                streamingURL: videoHref, // Also update streamingURL for consistency
                contentId: video.contentId,
                isEvent: video.isEvent,
                appPlayURL: video.appPlayURL
            )
            
            await MainActor.run {
                selectedVideoItem = resolvedVideo
            }
            
        } catch {
            await MainActor.run {
                playbackErrorMessage = "Failed to resolve video stream: \(error.localizedDescription)"
                showPlaybackErrorAlert = true
            }
        }
    }
}

// MARK: - Inline Header Card Component
struct InlineHeaderCard: View {
    let category: VideoCategory
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section (just image, no overlays) - fixed frame to prevent layout jump
            Button(action: onTap) {
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
                .frame(height: 180) // Fixed height based on typical 58:13 ratio
                .clipped()
            }
            .buttonStyle(PlainButtonStyle())
            
            // Bottom section with ALL content
            VStack(alignment: .leading, spacing: 16) {
                // Main content section
                VStack(alignment: .leading, spacing: 12) {
                    // Category name (like "NBA Finals")
                    Text(category.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    // Category description (like "The stage is set...") - only if different from name
                    if !category.description.isEmpty && category.description != category.name {
                        Text(category.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                    }
                }
                
                // Status button
                Button(action: onTap) {
                    if video.isLive {
                        Text("LIVE")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red)
                            .cornerRadius(25)
                    } else {
                        Text("Upcoming")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(25)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Metadata section - single line like other tiles
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
                    
                    // Only show date if it's not "in 0s"
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
                    
                    // Duration if available
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
        .liquidGlassCard(cornerRadius: 12, density: .light)
        .padding(.horizontal)
        .preferredColorScheme(.dark)
    }
    
    private func formatVideoDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
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
            // For inline header rows, use the dedicated InlineHeaderCard component
            if hasInlineHeaderTag {
                if let video = category.videos.first {
                    InlineHeaderCard(category: category, video: video) {
                        onVideoTap(video)
                    }
                }
            } else {
                // Standard hero tile behavior for non-inline headers
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
                            .aspectRatio(getAspectRatio(for: video), contentMode: .fit)
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
                            
                            // Content overlay for standard hero tiles
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
        let hasTag = category.tags.contains("inline-header")
        if hasTag {
        }
        return hasTag
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
    
    private func getAspectRatio(for video: VideoItem) -> CGFloat {
        // Check if this is inline-header content (should be 58:13 ratio)
        if video.type?.lowercased() == "inlineheader" {
            return 58.0 / 13.0  // ≈ 4.46:1
        }
        
        // Default to 16:9 for regular hero content
        return 16.0 / 9.0
    }
    
    @ViewBuilder
    private func videoCardForContent(video: VideoItem, onTap: @escaping () -> Void) -> some View {
        // Special case: rowCap tag or first item in breakout row
        if video.tags.contains("rowCap") || shouldUseSquareForFirstItem(video) {
            SquareThumbnailCard(video: video, onTap: onTap)
        } else {
            // Category-specific overrides
            let categoryName = category.name.lowercased()
            
            // Use cached layout type from VideoItem
            switch video.layoutType {
            case .poster where !categoryName.contains("shows"):
                PosterVideoCard(video: video, onTap: onTap)
            case .show, .poster:  // .poster with "shows" falls through to show layout
                ShowVideoCard(video: video, onTap: onTap)
            case .circle where isLeagueSportOrConference(category.name):
                CircleThumbnailCard(video: video, onTap: onTap)
            case .square where isNetwork(category.name):
                SquareThumbnailCard(video: video, onTap: onTap)
            case .large:
                LargeVideoCard(video: video, onTap: onTap)
            case .small:
                SmallVideoCard(video: video, onTap: onTap)
            default:
                MediumVideoCard(video: video, onTap: onTap)
            }
        }
    }
    
    
    
    private func shouldUseSquareForFirstItem(_ video: VideoItem) -> Bool {
        // Only use square layout for first item if it's a true BREAKOUT_ROW_LEAGUES category
        // AND this is the first video in the sorted list
        return hasBreakoutRowTag && video == sortedVideos().first
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
                                .aspectRatio(contentMode: .fit)
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
                        
                        // Video metadata: Network, Re-Air (if applicable), Event Name
                        VStack(alignment: .leading, spacing: 2) {
                            // Display metadata with proper wrapping
                            if hasVideoMetadata(video) {
                                Text(video.metadataText)
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
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
    
    
}

/// Poster video card: For 2:3 aspect ratio content like movies and shows
struct PosterVideoCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Image container with 2:3 aspect ratio
                Group {
                    if let thumbnailURL = video.thumbnailURL, let url = URL(string: thumbnailURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
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
                .frame(width: 120, height: 180) // 2:3 aspect ratio for posters
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
                        
                        // Video metadata: Network, Re-Air (if applicable), Event Name
                        VStack(alignment: .leading, spacing: 2) {
                            // Display metadata with proper wrapping
                            if hasVideoMetadata(video) {
                                Text(video.metadataText)
                                    .font(.system(size: 9))
                                    .foregroundColor(.gray)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
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
            .frame(width: 120)
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
    
}

/// Show video card: For 4:3 aspect ratio content like shows
struct ShowVideoCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Image container with 4:3 aspect ratio
                Group {
                    if let thumbnailURL = video.thumbnailURL, let url = URL(string: thumbnailURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
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
                .frame(width: 160, height: 120) // 4:3 aspect ratio for shows
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
                        
                        // Video metadata: Network, Re-Air (if applicable), Event Name
                        VStack(alignment: .leading, spacing: 2) {
                            // Display metadata with proper wrapping
                            if hasVideoMetadata(video) {
                                Text(video.metadataText)
                                    .font(.system(size: 9))
                                    .foregroundColor(.gray)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
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
                                .aspectRatio(contentMode: .fit)
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
                        
                        // Video metadata: Network, Re-Air (if applicable), Event Name
                        VStack(alignment: .leading, spacing: 2) {
                            // Display metadata with proper wrapping
                            if hasVideoMetadata(video) {
                                Text(video.metadataText)
                                    .font(.system(size: 9))
                                    .foregroundColor(.gray)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
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
                                .aspectRatio(contentMode: .fit)
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
                        
                        // Minimal metadata for small cards
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
    
    private func hasVideoMetadata(_ video: VideoItem) -> Bool {
        return video.network != nil || video.reAir != nil || video.eventName != nil
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
