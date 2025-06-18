import SwiftUI

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
    
    // MARK: - Full Card with Image
    private var fullCardWithImage: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image section
            articleImageView
            
            // Content section
            cardContent
        }
        .espnGlassCard(cornerRadius: 16)
        .padding(.horizontal)
        .onTapGesture {
            onArticleTap()
        }
    }
    
    // MARK: - Article Image View
    private var articleImageView: some View {
        ZStack {
            // Background image
            imageContainer
            
            // Play button overlay for videos
            if article.type == .video {
                playButtonOverlay
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
        .clipShape(imageClipShape)
        .background(.ultraThinMaterial, in: imageClipShape)
        .onTapGesture {
            handleImageTap()
        }
    }
    
    // MARK: - Image Container
    private var imageContainer: some View {
        Group {
            if let imageURL = article.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    imagePlaceholder
                }
            }
        }
    }
    
    // MARK: - Image Placeholder
    private var imagePlaceholder: some View {
        Rectangle()
            .fill(placeholderGradient)
            .overlay(
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            )
    }
    
    // MARK: - Placeholder Gradient
    private var placeholderGradient: LinearGradient {
        LinearGradient(
            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Image Clip Shape
    private var imageClipShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(cornerRadii: .init(
            topLeading: 12,
            bottomLeading: 0,
            bottomTrailing: 0,
            topTrailing: 12
        ))
    }
    
    // MARK: - Play Button Overlay
    @ViewBuilder
    private var playButtonOverlay: some View {
        if #available(iOS 18.0, *) {
            modernPlayButton
        } else {
            legacyPlayButton
        }
    }
    
    // MARK: - Modern Play Button (iOS 18+)
    @available(iOS 18.0, *)
    private var modernPlayButton: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 60, height: 60)
                .glassEffect(
                    .regular,
                    in: Circle()
                )
            
            playIcon
        }
    }
    
    // MARK: - Legacy Play Button
    private var legacyPlayButton: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 60, height: 60)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            playIcon
        }
    }
    
    // MARK: - Play Icon
    private var playIcon: some View {
        Image(systemName: "play.fill")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Handle Image Tap
    private func handleImageTap() {
        if article.type == .video && article.videoURL != nil {
            onVideoTap()
        } else {
            onArticleTap()
        }
    }
    
    // MARK: - Collapsed Card (No Image)
    private var collapsedCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header row
            collapsedCardHeader
            
            // Title
            Text(article.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            // Footer
            collapsedCardFooter
        }
        .padding(12)
        .espnGlassCard(cornerRadius: 12)
        .padding(.horizontal)
        .onTapGesture {
            onArticleTap()
        }
    }
    
    // MARK: - Collapsed Card Header
    private var collapsedCardHeader: some View {
        HStack {
            // Premium and Sport indicators
            premiumBadge
            sportBadge
            
            Spacer()
            
            // Time and author
            authorDateInfo
        }
    }
    
    // MARK: - Collapsed Card Footer
    private var collapsedCardFooter: some View {
        HStack {
            Spacer()
            engagementStats
        }
    }
    
    // MARK: - Card Content
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
            
            // Metadata
            cardMetadata
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    // MARK: - Card Metadata
    private var cardMetadata: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Row 1: Premium and Sport
            HStack {
                premiumBadge
                sportBadge
                Spacer()
            }
            
            // Row 2: Author, Date, and Engagement
            HStack {
                authorDateInfo
                Spacer()
                engagementStats
            }
        }
    }
    
    // MARK: - Premium Badge
    @ViewBuilder
    private var premiumBadge: some View {
        if article.isPremium {
            HStack(spacing: 3) {
                Image(systemName: "plus.circle.fill")
                    .font(.caption2)
                Text("ESPN+")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            .foregroundStyle(premiumGradient)
        }
    }
    
    // MARK: - Premium Gradient
    private var premiumGradient: LinearGradient {
        LinearGradient(
            colors: [Color.blue, Color.purple],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - Sport Badge
    @ViewBuilder
    private var sportBadge: some View {
        if let sport = article.sport {
            HStack(spacing: 4) {
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
        }
    }
    
    // MARK: - Author Date Info
    private var authorDateInfo: some View {
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
    
    // MARK: - Engagement Stats
    private var engagementStats: some View {
        HStack(spacing: 12) {
            // Likes
            HStack(spacing: 3) {
                Image(systemName: "heart")
                    .font(.caption)
                Text(formatNumber(article.likes))
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            
            // Comments
            HStack(spacing: 3) {
                Image(systemName: "message")
                    .font(.caption)
                Text(formatNumber(article.comments))
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Helper Functions
    private func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            return String(format: "%.1fK", Double(number) / 1000.0)
        }
        return "\(number)"
    }
}

// MARK: - Previews
#Preview("Article Card with Image") {
    ArticleCard(
        article: Article(
            title: "Lakers Win Thriller Against Warriors in OT",
            subtitle: "LeBron James hits game-winning three-pointer with 0.8 seconds left",
            author: "Adrian Wojnarowski",
            publishedDate: Date().addingTimeInterval(-3600),
            imageURL: "https://a.espncdn.com/photo/2024/1203/r1397384_1296x729_16-9.jpg",
            content: "The Lakers defeated the Warriors in an overtime thriller...",
            type: .news,
            readTime: 5,
            sport: .basketball,
            relatedTeams: [],
            likes: 1234,
            comments: 567,
            isPremium: false,
            articleURL: nil,
            videoURL: nil
        ),
        onArticleTap: {},
        onVideoTap: {}
    )
    .background(Color(UIColor.systemBackground))
}

#Preview("Article Card without Image") {
    ArticleCard(
        article: Article(
            title: "Breaking: Star Player Traded to Contender",
            subtitle: nil,
            author: "Shams Charania",
            publishedDate: Date().addingTimeInterval(-7200),
            imageURL: nil,
            content: "In a blockbuster trade...",
            type: .news,
            readTime: 3,
            sport: .basketball,
            relatedTeams: [],
            likes: 89,
            comments: 45,
            isPremium: true,
            articleURL: nil,
            videoURL: nil
        ),
        onArticleTap: {},
        onVideoTap: {}
    )
    .background(Color(UIColor.systemBackground))
}

#Preview("Video Card") {
    ArticleCard(
        article: Article(
            title: "Mahomes' Incredible 70-Yard TD Pass",
            subtitle: "Watch the play that sealed the game",
            author: "ESPN Video",
            publishedDate: Date().addingTimeInterval(-1800),
            imageURL: "https://a.espncdn.com/photo/2024/1203/r1397384_1296x729_16-9.jpg",
            content: "Patrick Mahomes threw an incredible touchdown pass...",
            type: .video,
            readTime: 2,
            sport: .football,
            relatedTeams: [],
            likes: 5678,
            comments: 890,
            isPremium: false,
            articleURL: nil,
            videoURL: "https://media.video-cdn.espn.com/2024/sample.mp4"
        ),
        onArticleTap: {},
        onVideoTap: {}
    )
    .background(Color(UIColor.systemBackground))
}
