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
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 8)
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
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
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