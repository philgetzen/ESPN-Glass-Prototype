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
    @State private var lastTapTime: Date = .distantPast
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
                            isRefreshing = false
                        }
                    
                case .loaded(let categories):
                    ScrollView {
                        LazyVStack(spacing: 24, pinnedViews: []) {
                            ForEach(categories) { category in
                                VideoCategorySection(
                                    category: category,
                                    onVideoTap: handleVideoTap
                                )
                                .id(category.id)
                            }
                        }
                        .padding(.vertical)
                    }
                    .preferredColorScheme(.dark)
                    
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
                    .ignoresSafeArea(.all)
            )
            .background(
                GeometryReader { _ in
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.8)
                        .allowsHitTesting(false)
                        .ignoresSafeArea(.all)
                }
                .ignoresSafeArea(.all)
            )
            .adaptiveBackground()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .espnToolbar(
                logoType: .standardLogo,
                onSettingsTap: { showSettings = true }
            )
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
                            selectedVideoItem = nil
                        }
                } else {
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
        .refreshable {
            await MainActor.run { isRefreshing = true }
            try? await Task.sleep(nanoseconds: 500_000_000)
            await loadVideoContentIfNeeded(force: true)
            try? await Task.sleep(nanoseconds: 800_000_000)
            await MainActor.run { isRefreshing = false }
        }
        .preferredColorScheme(.dark)
        .task {
            await loadVideoContentIfNeeded(force: false)
        }
        .espnPullToRefreshOverlay(isRefreshing: isRefreshing, topOffset: 120)
    }
    
    // MARK: - Data Loading
    
    private func loadVideoContentIfNeeded(force: Bool) async {
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
                if case .loading = viewState {
                    viewState = .error(error.localizedDescription)
                }
            }
        }
    }
    
    private func shouldRefresh() -> Bool {
        guard let lastRefresh = lastRefreshTime else {
            return true
        }
        
        let timeSinceRefresh = Date().timeIntervalSince(lastRefresh)
        return timeSinceRefresh >= refreshInterval
    }
    
    // MARK: - Video Playback Handling
    
    private func handleVideoTap(_ video: VideoItem) {
        let now = Date()
        guard now.timeIntervalSince(lastTapTime) > 0.3 else { return }
        lastTapTime = now
        
        if video.requiresESPNApp {
            if !hasShownESPNAppAlertThisSession {
                espnAppVideoItem = video
                showESPNAppAlert = true
                hasShownESPNAppAlertThisSession = true
            } else {
                openESPNApp(for: video)
            }
        } else {
            if let streamingURL = video.streamingURL, !streamingURL.isEmpty {
                if streamingURL.contains("/playback/video/") {
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
        
        guard let appPlayURLString = video.appPlayURL else {
            playbackErrorMessage = "No ESPN app deep link URL available"
            showPlaybackErrorAlert = true
            return
        }
        
        if let espnURL = URL(string: appPlayURLString) {
            if UIApplication.shared.canOpenURL(espnURL) {
                UIApplication.shared.open(espnURL)
            } else {
                if let webURL = video.streamingURL, let url = URL(string: webURL) {
                    UIApplication.shared.open(url)
                } else {
                    if let appStoreURL = URL(string: "https://apps.apple.com/app/espn-live-sports-scores/id317469184") {
                        UIApplication.shared.open(appStoreURL)
                    }
                }
            }
        }
    }
    
    private func resolvePlaybackURL(for video: VideoItem, apiURL: String) async {
        do {
            let videoHref = try await apiService.resolvePlaybackURL(from: apiURL)
            
            let resolvedVideo = VideoItem(
                title: video.title,
                description: video.description,
                thumbnailURL: video.thumbnailURL,
                videoURL: videoHref,
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
                streamingURL: videoHref,
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

// MARK: - Extensions

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

// MARK: - Preview

#Preview {
    WatchView(colorScheme: .constant(.dark))
}

#Preview("Dark Mode") {
    WatchView(colorScheme: .constant(.dark))
        .preferredColorScheme(.dark)
}
