import SwiftUI

// Import performance optimizations - they're in the same module
// so we don't need a separate import, but let me ensure they're accessible


struct HomeView: View {
    @State private var viewState = HomeViewState.loading
    @State private var selectedArticle: Article?
    @State private var selectedVideoArticle: Article?
    @State private var showSettings = false
    @State private var isRefreshing = false
    @State private var lastRefreshTime: Date?
    @Binding var colorScheme: ColorScheme?
    
    private let apiService = ESPNAPIService.shared
    private let refreshInterval: TimeInterval = 300 // 5 minutes
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewState {
                case .loading:
                    LoadingView("Loading articles...")
                        .onAppear {
                            // Ensure refresh overlay is off during initial loading
                            isRefreshing = false
                        }
                    
                case .loaded(let articles):
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(articles) { article in
                                ArticleCard(
                                    article: article,
                                    onArticleTap: {
                                        selectedArticle = article
                                    },
                                    onVideoTap: {
                                        if article.type == .video {
                                            selectedVideoArticle = article
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.vertical)
                    }
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.hidden)
                    .safeAreaInset(edge: .bottom) { Spacer().frame(height: 60) }
                    
                case .error(let errorMessage):
                    ErrorView(error: errorMessage, retry: { await loadArticlesIfNeeded(force: true) })
                    
                case .empty:
                    EmptyStateView(
                        icon: "newspaper",
                        title: "No Articles",
                        message: "Check back later for new content"
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .espnToolbar(
                logoType: .standardLogo,
                onSettingsTap: { showSettings = true }
            )
            .adaptiveBackground()
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
                    .preferredColorScheme(colorScheme)
            }
            .sheet(item: $selectedVideoArticle) { article in
                if let videoURL = article.videoURL, let url = URL(string: videoURL) {
                    VideoPlayerView(videoURL: url, article: article)
                        .preferredColorScheme(colorScheme)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(colorScheme: $colorScheme)
                    .preferredColorScheme(colorScheme)
            }
            .task {
                await loadArticlesIfNeeded(force: false)
            }
            .refreshable {
                await MainActor.run { isRefreshing = true }
                // Add delay to ensure refresh indicator shows
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                await loadArticlesIfNeeded(force: true)
                // Keep indicator visible longer after completion
                try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
                await MainActor.run { isRefreshing = false }
            }
        }
        .espnPullToRefreshOverlay(isRefreshing: isRefreshing, topOffset: 120)
    }
    
    private func loadArticlesIfNeeded(force: Bool) async {
        // Check if we need to refresh
        let needsRefresh = force || shouldRefresh()
        
        if !needsRefresh {
            return
        }
        
        
        // Only show loading state if we don't have articles yet
        await MainActor.run {
            if case .loaded(_) = viewState {
                // Keep existing articles during refresh
            } else {
                viewState = .loading
            }
        }
        
        do {
            // Fetch articles with optimized limit
            let newsArticles = try await apiService.fetchNewsFeed(limit: 30)
            
            // Convert with background processing
            let convertedArticles = await Task.detached(priority: .userInitiated) {
                newsArticles.map { Article(from: $0) }
            }.value
            
            // Update on main thread
            await MainActor.run {
                if convertedArticles.isEmpty {
                    viewState = .empty
                } else {
                    viewState = .loaded(convertedArticles)
                    lastRefreshTime = Date()
                }
            }
        } catch {
            await MainActor.run {
                // Only show error if we don't have cached articles
                if case .loading = viewState {
                    viewState = .error(error.localizedDescription)
                } else {
                }
            }
        }
        
        print("✨ Refresh complete")
    }
    
    private func shouldRefresh() -> Bool {
        guard let lastRefresh = lastRefreshTime else {
            return true // First time loading
        }
        
        let timeSinceRefresh = Date().timeIntervalSince(lastRefresh)
        return timeSinceRefresh >= refreshInterval
    }
}

#Preview {
    HomeView(colorScheme: .constant(.dark))
}
