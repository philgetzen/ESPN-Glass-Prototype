import Foundation
import SwiftUI

enum ArticleType: String, CaseIterable {
    case news = "News"
    case video = "Video"
    case podcast = "Podcast"
    case analysis = "Analysis"
    
    var icon: String {
        switch self {
        case .news:
            return "newspaper.fill"
        case .video:
            return "play.circle.fill"
        case .podcast:
            return "mic.fill"
        case .analysis:
            return "chart.line.uptrend.xyaxis"
        }
    }
}

struct Article: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String?
    let author: String
    let publishedDate: Date
    let imageURL: String?
    let content: String
    let type: ArticleType
    let readTime: Int // in minutes
    let sport: Sport?
    let relatedTeams: [Team]
    let likes: Int
    let comments: Int
    let isPremium: Bool
    let articleURL: String?
    let videoURL: String?
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: publishedDate, relativeTo: Date())
    }
    
    // Initialize from API response
    init(from newsArticle: NewsArticle) {
        self.id = UUID()
        self.title = newsArticle.headline ?? "Untitled"
        self.subtitle = newsArticle.description
        self.author = newsArticle.byline ?? "ESPN"
        
        // Parse date from ISO string
        if let publishedString = newsArticle.published {
            let formatter = ISO8601DateFormatter()
            self.publishedDate = formatter.date(from: publishedString) ?? Date()
        } else {
            self.publishedDate = Date()
        }
        
        // Get the first image URL
        self.imageURL = newsArticle.images?.first?.url
        
        // Content from description or empty
        self.content = newsArticle.description ?? ""
        
        // Determine type based on API type field and video content
        if let video = newsArticle.video, !video.isEmpty {
            self.type = .video
        } else if let apiType = newsArticle.type?.lowercased() {
            if apiType.contains("video") {
                self.type = .video
            } else if apiType.contains("podcast") {
                self.type = .podcast
            } else if apiType.contains("analysis") || apiType.contains("story") {
                self.type = .analysis
            } else {
                self.type = .news
            }
        } else {
            self.type = .news
        }
        
        // Estimate read time based on content length
        let wordCount = (newsArticle.description ?? "").split(separator: " ").count
        self.readTime = max(1, wordCount / 200) // Assuming 200 words per minute
        
        // Get sport from categories
        if let category = newsArticle.categories?.first,
           let sportId = category.sportId {
            self.sport = Sport.fromAPIId(sportId)
        } else {
            self.sport = nil
        }
        
        self.relatedTeams = []
        
        // Random engagement numbers for now (in real app, these would come from API)
        self.likes = Int.random(in: 100...10000)
        self.comments = Int.random(in: 10...1000)
        
        self.isPremium = newsArticle.premium ?? false
        self.articleURL = newsArticle.links?.web?.href
        
        // Extract video URL if available
        if let video = newsArticle.video?.first {
            self.videoURL = video.links?.source?.href
        } else {
            self.videoURL = nil
        }
    }
    
    // Manual initializer for mock data
    init(id: UUID = UUID(), title: String, subtitle: String?, author: String, publishedDate: Date, 
         imageURL: String?, content: String, type: ArticleType, readTime: Int,
         sport: Sport?, relatedTeams: [Team], likes: Int, comments: Int,
         isPremium: Bool = false, articleURL: String? = nil, videoURL: String? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.author = author
        self.publishedDate = publishedDate
        self.imageURL = imageURL
        self.content = content
        self.type = type
        self.readTime = readTime
        self.sport = sport
        self.relatedTeams = relatedTeams
        self.likes = likes
        self.comments = comments
        self.isPremium = isPremium
        self.articleURL = articleURL
        self.videoURL = videoURL
    }
}

extension Article {
    static let mockArticles: [Article] = [
        Article(
            title: "NBA free agent rankings: Futures of LeBron, Turner, more stars",
            subtitle: "Michael Willbon gets fired up over LeBron's place in the NBA's GOAT debate",
            author: "Kevin Pelton",
            publishedDate: Date().addingTimeInterval(-3600 * 2),
            imageURL: "lebron-article",
            content: "NBA free agency won't be the marquee part of this summer's offseason...",
            type: .news,
            readTime: 5,
            sport: .basketball,
            relatedTeams: [Team.mockNBATeams[0]],
            likes: 6800,
            comments: 532
        ),
        Article(
            title: "Shams shares Kevin Durant's main trade suitors with McAfee",
            subtitle: nil,
            author: "Shams Charania",
            publishedDate: Date().addingTimeInterval(-3600 * 4),
            imageURL: "durant-trade",
            content: "Latest updates on Kevin Durant trade rumors...",
            type: .video,
            readTime: 2,
            sport: .basketball,
            relatedTeams: [],
            likes: 4200,
            comments: 287
        ),
        Article(
            title: "Why Stephen A. has Game 3 coming down to Tyrese Haliburton",
            subtitle: "First Take debates the key to Game 3",
            author: "Stephen A. Smith",
            publishedDate: Date().addingTimeInterval(-3600 * 6),
            imageURL: "stephen-a",
            content: "Analysis of the upcoming Game 3 matchup...",
            type: .analysis,
            readTime: 3,
            sport: .basketball,
            relatedTeams: [Team.mockNBATeams[4]],
            likes: 3100,
            comments: 189
        ),
        Article(
            title: "What's next for Knicks after being denied permission to speak with Jason Kidd?",
            subtitle: nil,
            author: "Adrian Wojnarowski",
            publishedDate: Date().addingTimeInterval(-3600 * 8),
            imageURL: "knicks-coaching",
            content: "The New York Knicks coaching search continues...",
            type: .news,
            readTime: 4,
            sport: .basketball,
            relatedTeams: [],
            likes: 2900,
            comments: 156
        ),
        Article(
            title: "Udonis Haslem joins McAfee, fires up Indiana crowd with Pacers pick",
            subtitle: nil,
            author: "Pat McAfee",
            publishedDate: Date().addingTimeInterval(-3600 * 10),
            imageURL: "haslem-pacers",
            content: "Former Heat player shows support for Pacers...",
            type: .video,
            readTime: 1,
            sport: .basketball,
            relatedTeams: [Team.mockNBATeams[4]],
            likes: 2100,
            comments: 98
        ),
        Article(
            title: "Why Stephen A is 'ecstatic' about Aaron Rodgers as a Steelers fan",
            subtitle: nil,
            author: "Stephen A. Smith",
            publishedDate: Date().addingTimeInterval(-3600 * 12),
            imageURL: "rodgers-steelers",
            content: "Stephen A. explains his take on Aaron Rodgers...",
            type: .video,
            readTime: 2,
            sport: .football,
            relatedTeams: [],
            likes: 1800,
            comments: 142
        ),
        Article(
            title: "Mike Tannenbaum: Aaron Rodgers will be irrelevant by Thanksgiving",
            subtitle: nil,
            author: "Mike Tannenbaum",
            publishedDate: Date().addingTimeInterval(-3600 * 14),
            imageURL: "tannenbaum-rodgers",
            content: "Bold prediction about Aaron Rodgers' future...",
            type: .analysis,
            readTime: 3,
            sport: .football,
            relatedTeams: [],
            likes: 1500,
            comments: 234
        )
    ]
}