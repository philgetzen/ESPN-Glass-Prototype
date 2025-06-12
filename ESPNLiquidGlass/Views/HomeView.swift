import SwiftUI

struct HomeView: View {
    @State private var articles = Article.mockArticles
    @State private var selectedArticle: Article?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(articles) { article in
                        ArticleCard(article: article)
                            .onTapGesture {
                                selectedArticle = article
                            }
                    }
                }
                .padding(.vertical)
            }
            .background(.black)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .safeAreaInset(edge: .bottom) { Spacer().frame(height: 60) }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .glowEffect(
                                color: .blue,
                                radius: 3,
                                intensity: .subtle,
                                pulsation: .none
                            )
                    }
                    .liquidGlassButtonStyle(cornerRadius: 8)
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
            // Image with Liquid Glass background
            Rectangle()
                .fill(LinearGradient(
                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
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
        .liquidGlassCard(cornerRadius: 16, density: .medium)
        .padding(.horizontal)
    }
    
    func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            return String(format: "%.1fK", Double(number) / 1000.0)
        }
        return "\(number)"
    }
}
