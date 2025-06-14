import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @Environment(\.dismiss) var dismiss
    @State private var isLiked = false
    @State private var likeCount: Int
    
    init(article: Article) {
        self.article = article
        self._likeCount = State(initialValue: article.likes)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Hero Image/Video
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
                        } else {
                            Rectangle()
                                .fill(LinearGradient(
                                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: article.type.icon)
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                        Text("No Image Available")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                )
                        }
                    }
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(alignment: .center) {
                        if article.type == .video {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .shadow(radius: 10)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Title
                        Text(article.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        // Subtitle
                        if let subtitle = article.subtitle {
                            Text(subtitle)
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        
                        // Article metadata
                        HStack {
                            if article.isPremium {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.caption)
                                    Text("ESPN+")
                                        .font(.caption)
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
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Text(sport.rawValue.uppercased())
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            }
                            
                            Spacer()
                            
                            Text(article.type.rawValue.uppercased())
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(4)
                                .foregroundColor(.primary)
                        }
                        
                        // Author and Date
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(article.author)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(article.formattedDate)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // Read Time
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption)
                                Text("\(article.readTime) min read")
                                    .font(.caption)
                            }
                            .foregroundColor(.gray)
                        }
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        // Engagement Bar
                        HStack(spacing: 24) {
                            Button(action: {
                                isLiked.toggle()
                                likeCount += isLiked ? 1 : -1
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: isLiked ? "heart.fill" : "heart")
                                        .font(.title3)
                                    Text(formatNumber(likeCount))
                                        .font(.subheadline)
                                }
                                .foregroundColor(isLiked ? .red : .gray)
                            }
                            
                            Button(action: {}) {
                                HStack(spacing: 6) {
                                    Image(systemName: "message")
                                        .font(.title3)
                                    Text(formatNumber(article.comments))
                                        .font(.subheadline)
                                }
                                .foregroundColor(.gray)
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "bookmark")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        // Article Content
                        VStack(alignment: .leading, spacing: 20) {
                            if !article.content.isEmpty {
                                Text(article.content)
                                    .font(.body)
                                    .foregroundColor(.primary.opacity(0.9))
                                    .lineSpacing(8)
                            }
                            
                            // Read full article section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Rectangle()
                                        .fill(Color.red)
                                        .frame(width: 3, height: 20)
                                    Text("Full Article")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                                
                                Text("This is a preview. Read the complete article with in-depth analysis, quotes, and additional reporting on ESPN.com.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineSpacing(4)
                                
                                if let articleURL = article.articleURL, let url = URL(string: articleURL) {
                                    Link(destination: url) {
                                        HStack {
                                            Text("Continue reading on ESPN.com")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "arrow.up.right")
                                                .font(.subheadline)
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.red, Color.red.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Related Teams
                        if !article.relatedTeams.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("RELATED TEAMS")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 16) {
                                    ForEach(article.relatedTeams) { team in
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(team.primaryColor)
                                                .frame(width: 30, height: 30)
                                            
                                            Text(team.fullName)
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.top)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .adaptiveBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "textformat")
                                .foregroundColor(.primary)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
    }
    
    func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            return String(format: "%.1fK", Double(number) / 1000.0)
        }
        return "\(number)"
    }
}