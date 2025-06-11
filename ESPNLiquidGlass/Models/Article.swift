import Foundation
import SwiftUI

enum ArticleType {
    case news
    case video
    case podcast
    case analysis
    
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
    let id = UUID()
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
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: publishedDate, relativeTo: Date())
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