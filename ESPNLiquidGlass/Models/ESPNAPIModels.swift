import Foundation

// MARK: - API Response Models

struct NewsResponse: Codable {
    let headlines: [NewsArticle]?
    let resultsCount: Int?
    let resultsOffset: Int?
}

struct LeagueNewsResponse: Codable {
    let articles: [NewsArticle]?
}

struct NewsArticle: Codable {
    let id: Int?
    let headline: String?
    let description: String?
    let published: String?
    let byline: String?
    let type: String?
    let premium: Bool?
    let source: String?
    let links: Links?
    let images: [ArticleImage]?
    let video: [VideoContent]?
    let categories: [Category]?
    
    struct Links: Codable {
        let web: WebLink?
        let mobile: MobileLink?
        
        struct WebLink: Codable {
            let href: String?
        }
        
        struct MobileLink: Codable {
            let href: String?
        }
    }
    
    struct ArticleImage: Codable {
        let url: String?
        let width: Int?
        let height: Int?
        let caption: String?
    }
    
    struct VideoContent: Codable {
        let id: Int?
        let headline: String?
        let description: String?
        let thumbnail: String?
        let source: String?
        let duration: Int?
        let links: VideoLinks?
        
        struct VideoLinks: Codable {
            let source: VideoSource?
            
            struct VideoSource: Codable {
                let href: String?
            }
        }
    }
    
    struct Category: Codable {
        let description: String?
        let type: String?
        let sportId: Int?
        let leagueId: Int?
        let league: League?
        let uid: String?
        
        struct League: Codable {
            let description: String?
            let links: Links?
            
            struct Links: Codable {
                let web: WebLink?
                
                struct WebLink: Codable {
                    let href: String?
                }
            }
        }
    }
}

// MARK: - Sports Scores Models

struct SportGameData {
    let league: String
    let leagueName: String
    let leagueAbbreviation: String
    let icon: String
    let events: [ESPNEvent]
}

struct ESPNEvent: Codable {
    let id: String?
    let uid: String?
    let date: String?
    let name: String?
    let shortName: String?
    let season: Season?
    let competitions: [Competition]?
    let status: ESPNGameStatus?
    let venue: Venue?
    
    var isLive: Bool {
        status?.type?.state == "in"
    }
    
    var isUpcoming: Bool {
        status?.type?.state == "pre"
    }
    
    var isFinal: Bool {
        status?.type?.state == "post"
    }
    
    struct Season: Codable {
        let year: Int?
        let type: Int?
        let slug: String?
    }
    
    struct Competition: Codable {
        let id: String?
        let uid: String?
        let date: String?
        let timeValid: Bool?
        let neutralSite: Bool?
        let conferenceCompetition: Bool?
        let boxscoreAvailable: Bool?
        let commentaryAvailable: Bool?
        let liveAvailable: Bool?
        let onWatchESPN: Bool?
        let recent: Bool?
        let competitors: [Competitor]?
        let notes: [Note]?
        let situation: ESPNSituation?
        let status: ESPNGameStatus?
        let broadcasts: [ESPNBroadcast]?
        let leaders: [Leader]?
        let format: Format?
        let startDate: String?
        let geoBroadcasts: [GeoBroadcast]?
        let headlines: [Headline]?
        
        struct Competitor: Codable {
            let id: String?
            let uid: String?
            let type: String?
            let order: Int?
            let homeAway: String?
            let winner: Bool?
            let team: TeamInfo?
            let score: String?
            let linescores: [Linescore]?
            let statistics: [Statistic]?
            let leaders: [Leader]?
            let curatedRank: CuratedRank?
            let records: [Record]?
            
            struct TeamInfo: Codable {
                let id: String?
                let uid: String?
                let location: String?
                let name: String?
                let abbreviation: String?
                let displayName: String?
                let shortDisplayName: String?
                let color: String?
                let alternateColor: String?
                let isActive: Bool?
                let logo: String?
                let links: [Link]?
            }
            
            struct Record: Codable {
                let name: String?
                let abbreviation: String?
                let type: String?
                let summary: String?
            }
            
            struct Linescore: Codable {
                let value: Double?
            }
            
            struct Statistic: Codable {
                let name: String?
                let abbreviation: String?
                let displayValue: String?
            }
            
            struct CuratedRank: Codable {
                let current: Int?
            }
            
            struct Link: Codable {
                let rel: [String]?
                let href: String?
            }
        }
        
        struct Note: Codable {
            let type: String?
            let headline: String?
        }
        
        struct Leader: Codable {
            let name: String?
            let displayName: String?
            let shortDisplayName: String?
            let abbreviation: String?
            let leaders: [LeaderDetail]?
            
            struct LeaderDetail: Codable {
                let displayValue: String?
                let value: Double?
                let athlete: Athlete?
                let team: Team?
                
                struct Athlete: Codable {
                    let id: String?
                    let fullName: String?
                    let displayName: String?
                    let shortName: String?
                    let links: [Link]?
                    let headshot: String?
                    let jersey: String?
                    let position: Position?
                    let team: Team?
                    
                    struct Position: Codable {
                        let abbreviation: String?
                    }
                }
                
                struct Team: Codable {
                    let id: String?
                }
                
                struct Link: Codable {
                    let rel: [String]?
                    let href: String?
                }
            }
        }
        
        struct Format: Codable {
            let regulation: Regulation?
            
            struct Regulation: Codable {
                let periods: Int?
            }
        }
        
        struct GeoBroadcast: Codable {
            let type: BroadcastType?
            let market: Market?
            let media: Media?
            let lang: String?
            let region: String?
            
            struct BroadcastType: Codable {
                let id: String?
                let shortName: String?
            }
            
            struct Market: Codable {
                let id: String?
                let type: String?
            }
            
            struct Media: Codable {
                let shortName: String?
            }
        }
        
        struct Headline: Codable {
            let description: String?
            let type: String?
            let shortLinkText: String?
        }
    }
    
    struct Venue: Codable {
        let id: String?
        let fullName: String?
        let address: Address?
        let capacity: Int?
        let indoor: Bool?
        
        struct Address: Codable {
            let city: String?
            let state: String?
        }
    }
}

struct ESPNGameStatus: Codable {
    let clock: Double?
    let displayClock: String?
    let period: Int?
    let type: StatusType?
    
    struct StatusType: Codable {
        let id: String?
        let name: String?
        let state: String?
        let completed: Bool?
        let description: String?
        let detail: String?
        let shortDetail: String?
    }
}

struct ESPNSituation: Codable {
    let lastPlay: ESPNLastPlay?
    let down: Int?
    let yardLine: Int?
    let distance: Int?
    let downDistanceText: String?
    let shortDownDistanceText: String?
    let possessionText: String?
    let isRedZone: Bool?
}

struct ESPNLastPlay: Codable {
    let id: String?
    let type: ESPNPlayType?
    let text: String?
}

struct ESPNPlayType: Codable {
    let id: String?
    let text: String?
}

struct ESPNBroadcast: Codable {
    let market: String?
    let names: [String]?
}

// MARK: - Scoreboard Response

struct ScoreboardResponse: Codable {
    let leagues: [League]?
    let events: [ESPNEvent]?
    
    struct League: Codable {
        let id: String?
        let uid: String?
        let name: String?
        let abbreviation: String?
        let slug: String?
        let season: Season?
        let logos: [Logo]?
        
        struct Season: Codable {
            let year: Int?
            let startDate: String?
            let endDate: String?
            let displayName: String?
            let type: SeasonType?
            
            struct SeasonType: Codable {
                let id: String?
                let type: Int?
                let name: String?
                let abbreviation: String?
            }
        }
        
        struct Logo: Codable {
            let href: String?
            let width: Int?
            let height: Int?
            let alt: String?
            let rel: [String]?
            let lastUpdated: String?
        }
    }
}

// MARK: - Video API Models

/// Video category containing a collection of videos
struct VideoCategory: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let videos: [VideoItem]
    let isLive: Bool
    let priority: Int
    let tags: [String]
    let showTitle: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, description, videos, isLive, priority, tags, showTitle
    }
}

/// Layout type for video cards
enum VideoLayoutType {
    case poster  // 2:3 aspect ratio (movies)
    case show    // 4:3 aspect ratio (shows)
    case circle  // Circular thumbnails (leagues/sports)
    case square  // Square thumbnails (networks/channels)
    case large   // Large cards
    case medium  // Medium cards (default)
    case small   // Small cards
}

/// Individual video item within a category
struct VideoItem: Identifiable, Codable, Equatable {
    let id = UUID()
    let title: String
    let description: String?
    let thumbnailURL: String?
    let videoURL: String?
    let duration: TimeInterval?
    let publishedDate: Date
    let sport: String?
    let league: String?
    let isLive: Bool
    let viewCount: Int?
    let tags: [String]
    let autoplay: Bool
    let showMetadata: Bool // Whether to show metadata beneath tile
    let size: String? // Tile size: "lg", "md", "sm"
    let type: String? // Content type from ESPN API
    let network: String? // Network/channel information
    let reAir: String? // Re-air information if applicable
    let eventName: String? // Event name
    let ratio: String? // Aspect ratio from ESPN API (e.g., "2:3", "16:9")
    let authType: [String]? // Authentication types required for this video
    let streamingURL: String? // Direct streaming URL from appPlay link
    let contentId: String? // ESPN content ID for deep linking
    let isEvent: Bool? // Whether this is event-based content (live games, etc.)
    let appPlayURL: String? // ESPN app deep link URL from API
    
    var requiresESPNApp: Bool {
        guard let authType = authType else { return false }
        let restrictedTypes = ["mvpd", "direct", "flagship", "isp"]
        return authType.contains(where: restrictedTypes.contains)
    }
    
    // Cached metadata text to prevent recalculation on every render
    var metadataText: String {
        var components: [String] = []
        
        // Add network if available and not generic
        if let network = network, !network.isEmpty {
            components.append(network)
        }
        
        // Add league/sport info if available and different from network
        if let league = league, !league.isEmpty, league != "ESPN" {
            // Don't duplicate if league is same as network
            if network != league {
                components.append(league)
            }
        }
        
        // Add re-air info if applicable
        if let reAir = reAir {
            components.append(reAir)
        }
        
        return components.joined(separator: " • ")
    }
    
    // Cached layout type decisions to prevent repeated computation during scrolling
    var layoutType: VideoLayoutType {
        // PRIORITY 1: Check if content is playable (should always be 16:9 regardless of other factors)
        let isPlayable = videoURL != nil || streamingURL != nil || appPlayURL != nil || 
                        isLive || isEvent == true
        if isPlayable {
            switch size?.lowercased() {
            case "lg", "large":
                return .large
            case "sm", "small":
                return .small
            default:
                return .medium
            }
        }
        
        // PRIORITY 2: Content type analysis for non-playable logo/branding content
        // Check for circle layout (leagues, sports, conferences) - these should always be circles
        if type?.lowercased() == "league" ||
           type?.lowercased() == "sport" ||
           type?.lowercased() == "conference" ||
           title.lowercased().contains("league") ||
           title.lowercased().contains("sport") ||
           title.lowercased().contains("conference") ||
           tags.contains(where: { $0.lowercased().contains("league") }) ||
           tags.contains(where: { $0.lowercased().contains("sport") }) {
            return .circle
        }
        
        // Check for square layout (networks, channels) - these should always be squares
        if type?.lowercased() == "network" ||
           type?.lowercased() == "channel" ||
           title.lowercased().contains("network") ||
           title.lowercased().contains("channel") ||
           title.lowercased().contains("espn") ||
           tags.contains("square") ||
           tags.contains(where: { $0.lowercased().contains("network") }) ||
           tags.contains(where: { $0.lowercased().contains("channel") }) {
            return .square
        }
        
        // PRIORITY 3: Use ESPN API-provided ratio field for other content
        if let ratio = ratio {
            switch ratio {
            case "16:9":
                // API says this is 16:9 content - respect it for non-logo content
                switch size?.lowercased() {
                case "lg", "large":
                    return .large
                case "sm", "small":
                    return .small
                default:
                    return .medium
                }
            case "1:1":
                // API says this is 1:1 content, but we already handled logos above
                // This might be other square content
                return .square
            case "2:3":
                return .poster
            case "4:3":
                return .show
            case "58:13":
                // Wide banner format for inline headers - treat as large 16:9
                return .large
            default:
                // Unknown ratio from API, fall through to content analysis
                break
            }
        }
        
        // PRIORITY 4: Content type analysis for remaining content
        // Check for poster/movie content (2:3)
        if type?.lowercased().contains("movie") == true ||
           type?.lowercased().contains("film") == true {
            return .poster
        }
        
        // Check for shows content (4:3)
        if type?.lowercased() == "show" {
            return .show
        }
        
        // PRIORITY 5: Size-based layout fallback
        switch size?.lowercased() {
        case "lg", "large":
            return .large
        case "sm", "small":
            return .small
        default:
            return .medium
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case title, description, thumbnailURL, videoURL, duration
        case publishedDate, sport, league, isLive, viewCount, tags, autoplay, showMetadata, size, type
        case network, reAir, eventName, ratio, authType, streamingURL, contentId, isEvent, appPlayURL
    }
}

/// Video category types
enum VideoCategoryType: String, CaseIterable {
    case live = "Live Now"
    case highlights = "Game Highlights" 
    case breakingNews = "Breaking News"
    case analysis = "Analysis & Commentary"
    case topVideos = "Top Videos"
    case recentlyAdded = "Recently Added"
    
    var description: String {
        switch self {
        case .live:
            return "Live streams and events happening now"
        case .highlights:
            return "Best moments and game highlights"
        case .breakingNews:
            return "Latest breaking sports news videos"
        case .analysis:
            return "Expert commentary and analysis"
        case .topVideos:
            return "Most popular sports videos"
        case .recentlyAdded:
            return "Latest videos added to the platform"
        }
    }
    
    var isLive: Bool {
        return self == .live
    }
}

// MARK: - Extensions for creating VideoItem from NewsArticle
extension VideoItem {
    init(from article: NewsArticle) {
        self.title = article.headline ?? "Untitled Video"
        self.description = article.description
        self.thumbnailURL = article.images?.first?.url
        self.videoURL = article.video?.first?.links?.source?.href
        self.duration = article.video?.first?.duration.map { TimeInterval($0) }
        
        // Parse published date from string
        if let publishedString = article.published {
            let formatter = ISO8601DateFormatter()
            self.publishedDate = formatter.date(from: publishedString) ?? Date()
        } else {
            self.publishedDate = Date()
        }
        
        self.sport = article.categories?.first?.sportId.map { String($0) }
        self.league = article.categories?.first?.league?.description
        self.isLive = false // ESPN API videos are typically recorded content
        self.viewCount = nil // Not available in ESPN API
        self.tags = [] // Keywords not available in current NewsArticle model
        self.autoplay = false // Default to no autoplay
        self.showMetadata = true // Default to showing metadata
        self.size = "md" // Default size for news articles
        self.type = article.type // Content type from news article
        self.network = nil // Not available in news articles
        self.reAir = nil // Not available in news articles
        self.eventName = nil // Not available in news articles
        self.ratio = nil // Not available in news articles
        self.authType = nil // Not available in news articles
        self.streamingURL = nil // Not available in news articles
        self.contentId = nil // Not available in news articles
        self.isEvent = nil // Not available in news articles
        self.appPlayURL = nil // Not available in news articles
    }
}