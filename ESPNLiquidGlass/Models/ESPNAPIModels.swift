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