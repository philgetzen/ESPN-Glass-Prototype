import SwiftUI

struct HomeView: View {
    @State private var articles = Article.mockArticles
    @State private var selectedArticle: Article?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(articles) { article in
                        ArticleCard(article: article)
                            .onTapGesture {
                                selectedArticle = article
                            }
                        
                        if article.id != articles.last?.id {
                            Divider()
                                .background(Color.gray.opacity(0.3))
                        }
                    }
                }
                .background(Color.black)
            }
            .background(Color.black)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
            }
        }
    }
}

struct ArticleCard: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image
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
            
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(article.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(3)
                
                // Subtitle
                if let subtitle = article.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                // Metadata
                HStack {
                    if let sport = article.sport {
                        Text(sport.rawValue.uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text(article.author)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text(article.formattedDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Engagement
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.caption)
                            Text(formatNumber(article.likes))
                                .font(.caption)
                        }
                        .foregroundColor(.red)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "message.fill")
                                .font(.caption)
                            Text(formatNumber(article.comments))
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.black)
    }
    
    func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            return String(format: "%.1fK", Double(number) / 1000.0)
        }
        return "\(number)"
    }
}