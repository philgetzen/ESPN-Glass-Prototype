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

struct ArticleCard: View {
    let article: Article
    let onArticleTap: () -> Void
    let onVideoTap: () -> Void
    
    var body: some View {
        if article.imageURL != nil {
            // Full card with image
            fullCardWithImage
        } else {
            // Collapsed card without image
            collapsedCard
        }
    }
    
    private var fullCardWithImage: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image with Liquid Glass background
            Group {
                if let imageURL = article.imageURL, let url = URL(string: imageURL) {
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
                                    .progressViewStyle(CircularProgressViewStyle())
                            )
                    }
                }
            }
            .aspectRatio(16/9, contentMode: .fit)
            .liquidGlassBackground(density: .light, flowDirection: .natural)
            .overlay(alignment: .center) {
                if article.type == .video {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .glowEffect(
                            color: .white,
                            radius: 10,
                            intensity: .medium,
                            pulsation: .gentle
                        )
                }
            }
            .onTapGesture {
                if article.type == .video && article.videoURL != nil {
                    onVideoTap()
                } else {
                    onArticleTap()
                }
            }
            
            cardContent
        }
        .liquidGlassCard(cornerRadius: 16, density: .medium)
        .padding(.horizontal)
        .onTapGesture {
            onArticleTap()
        }
    }
    
    private var collapsedCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Premium and Sport indicators
                if article.isPremium {
                    HStack(spacing: 2) {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption2)
                        Text("ESPN+")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
                
                if let sport = article.sport {
                    if article.isPremium {
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    Text(sport.rawValue.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                if article.type == .video {
                    if article.sport != nil || article.isPremium {
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    Text("VIDEO")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Time and author
                HStack(spacing: 4) {
                    Text(article.author)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.6))
                    Text(article.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Title
            Text(article.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            // Bottom engagement
            HStack {
                Spacer()
                
                // Simplified engagement
                HStack(spacing: 12) {
                    HStack(spacing: 2) {
                        Image(systemName: "heart")
                            .font(.caption2)
                        Text(formatNumber(article.likes))
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 2) {
                        Image(systemName: "message")
                            .font(.caption2)
                        Text(formatNumber(article.comments))
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .liquidGlassCard(cornerRadius: 12, density: .light)
        .padding(.horizontal)
        .onTapGesture {
            onArticleTap()
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(article.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(3)
            
            // Subtitle (hidden for video articles)
            if let subtitle = article.subtitle, article.type != .video {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Metadata row 1: Premium, Sport, Type
            HStack {
                if article.isPremium {
                    HStack(spacing: 3) {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption2)
                        Text("ESPN+")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
                
                if let sport = article.sport {
                    if article.isPremium {
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    Text(sport.rawValue.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                if article.type == .video {
                    if article.sport != nil || article.isPremium {
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    Text("VIDEO")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            
            // Metadata row 2: Author and Date
            HStack {
                Text(article.author)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.6))
                
                Text(article.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Simplified engagement
                HStack(spacing: 12) {
                    HStack(spacing: 3) {
                        Image(systemName: "heart")
                            .font(.caption)
                        Text(formatNumber(article.likes))
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 3) {
                        Image(systemName: "message")
                            .font(.caption)
                        Text(formatNumber(article.comments))
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            return String(format: "%.1fK", Double(number) / 1000.0)
        }
        return "\(number)"
    }
}
