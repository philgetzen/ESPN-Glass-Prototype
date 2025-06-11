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
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
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
                            .foregroundColor(.white)
                        
                        // Subtitle
                        if let subtitle = article.subtitle {
                            Text(subtitle)
                                .font(.title3)
                                .foregroundColor(.gray)
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
                                    .foregroundColor(.white)
                                
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
                        Text(article.content)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(8)
                        
                        // Mock additional content
                        ForEach(0..<3) { _ in
                            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(8)
                                .padding(.top)
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
                                                .foregroundColor(.white)
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
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "textformat")
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.white)
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