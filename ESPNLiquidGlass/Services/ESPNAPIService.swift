import Foundation

final class ESPNAPIService: Sendable {
    static let shared = ESPNAPIService()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        self.session = URLSession.shared
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    // Base URLs
    private let newsBaseURL = "https://now.core.api.espn.com"
    private let siteAPIBaseURL = "https://site.api.espn.com"
    
    enum APIError: Error {
        case invalidURL
        case noData
        case decodingError
        case networkError(Error)
    }
    
    // Fetch general news feed
    func fetchNewsFeed(sport: String? = nil, limit: Int = 50) async throws -> [NewsArticle] {
        var components = URLComponents(string: "\(newsBaseURL)/v1/sports/news")
        components?.queryItems = [
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        if let sport = sport {
            components?.queryItems?.append(URLQueryItem(name: "sport", value: sport))
        }
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, _) = try await session.data(for: request)
            
            // Debug: Check for video content in response
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let headlines = json["headlines"] as? [[String: Any]] {
                let videoCount = headlines.filter { headline in
                    if let video = headline["video"] as? [Any] {
                        return !video.isEmpty
                    }
                    return false
                }.count
                print("📹 Found \(videoCount) articles with video content out of \(headlines.count) total")
                
                // Check first few articles for video structure
                for (index, headline) in headlines.prefix(5).enumerated() {
                    if let video = headline["video"] as? [[String: Any]], !video.isEmpty {
                        print("📹 Article \(index) has \(video.count) videos")
                        if let firstVideo = video.first {
                            print("📹 Video keys: \(Array(firstVideo.keys))")
                        }
                    }
                }
            }
            
            let newsResponse = try decoder.decode(NewsResponse.self, from: data)
            return newsResponse.headlines ?? []
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // Fetch league-specific news
    func fetchLeagueNews(sport: String, league: String, limit: Int = 50) async throws -> [NewsArticle] {
        let urlString = "\(siteAPIBaseURL)/apis/site/v2/sports/\(sport)/\(league)/news"
        
        var components = URLComponents(string: urlString)
        components?.queryItems = [
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, _) = try await session.data(for: request)
            let response = try decoder.decode(LeagueNewsResponse.self, from: data)
            return response.articles ?? []
        } catch {
            throw APIError.networkError(error)
        }
    }
}

