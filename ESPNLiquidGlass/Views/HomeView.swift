import SwiftUI

struct HomeView: View {
    @State private var viewState = HomeViewState.loading
    @State private var selectedArticle: Article?
    @State private var selectedVideoArticle: Article?
    @State private var showSettings = false
    @Binding var colorScheme: ColorScheme?
    
    private let apiService = ESPNAPIService.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewState {
                case .loading:
                    LoadingView("Loading articles...")
                    
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
                    .safeAreaInset(edge: .bottom) { Spacer().frame(height: 60) }
                    
                case .error(let errorMessage):
                    ErrorView(error: errorMessage, retry: loadArticles)
                    
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
                await loadArticles()
            }
            .refreshable {
                await loadArticles()
            }
        }
    }
    
    private func loadArticles() async {
        await MainActor.run {
            viewState = .loading
        }
        
        do {
            // Fetch general news feed
            let newsArticles = try await apiService.fetchNewsFeed(limit: 30)
            
            // Convert API articles to our Article model
            let convertedArticles = newsArticles.map { Article(from: $0) }
            
            // Update on main thread
            await MainActor.run {
                if convertedArticles.isEmpty {
                    viewState = .empty
                } else {
                    viewState = .loaded(convertedArticles)
                }
            }
        } catch {
            await MainActor.run {
                viewState = .error(error.localizedDescription)
            }
        }
    }
}

#Preview {
    HomeView(colorScheme: .constant(.dark))
}
