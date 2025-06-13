import SwiftUI

struct HomeView: View {
    @State private var articles: [Article] = []
    @State private var selectedArticle: Article?
    @State private var selectedVideoArticle: Article?
    @State private var showSettings = false
    @State private var isLoading = true
    @State private var errorMessage: String?
    @Binding var colorScheme: ColorScheme?
    
    private let apiService = ESPNAPIService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    ProgressView("Loading articles...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(UIColor.systemBackground))
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Error loading articles")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task {
                                await loadArticles()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground))
                } else {
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
            .background(Color(UIColor.systemBackground))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .safeAreaInset(edge: .bottom) { Spacer().frame(height: 60) }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("ESPN_Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .medium))
                            .glowEffect(
                                color: .blue,
                                radius: 3,
                                intensity: .subtle,
                                pulsation: .none
                            )
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .medium))
                            .glowEffect(
                                color: .gray,
                                radius: 3,
                                intensity: .subtle,
                                pulsation: .none
                            )
                    }
                }
            }
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
            }
            .sheet(item: $selectedVideoArticle) { article in
                if let videoURL = article.videoURL, let url = URL(string: videoURL) {
                    VideoPlayerView(videoURL: url, article: article)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(colorScheme: $colorScheme)
                    .preferredColorScheme(colorScheme)
            }
                }
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
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch general news feed
            let newsArticles = try await apiService.fetchNewsFeed(limit: 30)
            
            // Convert API articles to our Article model
            let convertedArticles = newsArticles.map { Article(from: $0) }
            
            // Update on main thread
            await MainActor.run {
                self.articles = convertedArticles
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                // Fall back to mock data if API fails
                self.articles = Article.mockArticles
            }
        }
    }
}

