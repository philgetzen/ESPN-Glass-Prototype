import Foundation

// Custom delegate class to handle SSL certificate validation
private final class ESPNURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // WARNING: This bypasses SSL certificate validation - ONLY for development!
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }
        completionHandler(.performDefaultHandling, nil)
    }
}

final class ESPNAPIService: Sendable {
    static let shared = ESPNAPIService()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let sessionDelegate = ESPNURLSessionDelegate()
    
    private init() {
        // Initialize decoder
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Create a custom URLSession configuration for development
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        
        // Create session with custom delegate for development
        self.session = URLSession(configuration: config, delegate: sessionDelegate, delegateQueue: nil)
    }
    
    // Base URLs
    private let newsBaseURL = "https://now.core.api.espn.com"
    private let siteAPIBaseURL = "https://site.api.espn.com"
    
    enum APIError: Error {
        case invalidURL
        case noData
        case decodingError
        case invalidResponse
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
    
    // Fetch scores for a specific date
    func fetchScoresForDate(_ date: Date, sports: [String]) async -> [SportGameData] {
        var allSportsData: [SportGameData] = []
        
        // Format date for API
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: date)
        
        await withTaskGroup(of: SportGameData?.self) { group in
            for sport in sports {
                group.addTask {
                    await self.fetchSportScores(sport: sport, date: dateString)
                }
            }
            
            for await sportData in group {
                if let sportData = sportData {
                    allSportsData.append(sportData)
                }
            }
        }
        
        // Sort by sport priority
        let sportOrder = ["NFL", "NBA", "MLB", "NHL", "NCAAF", "NCAAM", "WNBA", "MLS", "PGA"]
        allSportsData.sort { sport1, sport2 in
            let index1 = sportOrder.firstIndex(of: sport1.leagueAbbreviation) ?? sportOrder.count
            let index2 = sportOrder.firstIndex(of: sport2.leagueAbbreviation) ?? sportOrder.count
            return index1 < index2
        }
        
        return allSportsData
    }
    
    private func fetchSportScores(sport: String, date: String) async -> SportGameData? {
        let urlString: String
        
        switch sport.lowercased() {
        case "nba":
            urlString = "https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard?dates=\(date)"
        case "nfl":
            urlString = "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard?dates=\(date)"
        case "mlb":
            urlString = "https://site.api.espn.com/apis/site/v2/sports/baseball/mlb/scoreboard?dates=\(date)"
        case "nhl":
            urlString = "https://site.api.espn.com/apis/site/v2/sports/hockey/nhl/scoreboard?dates=\(date)"
        case "wnba":
            urlString = "https://site.api.espn.com/apis/site/v2/sports/basketball/wnba/scoreboard?dates=\(date)"
        case "ncaaf":
            urlString = "https://site.api.espn.com/apis/site/v2/sports/football/college-football/scoreboard?dates=\(date)&groups=80"
        case "ncaam":
            urlString = "https://site.api.espn.com/apis/site/v2/sports/basketball/mens-college-basketball/scoreboard?dates=\(date)&groups=50"
        case "mls":
            urlString = "https://site.api.espn.com/apis/site/v2/sports/soccer/usa.1/scoreboard?dates=\(date)"
        default:
            return nil
        }
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await session.data(from: url)
            let response = try decoder.decode(ScoreboardResponse.self, from: data)
            
            guard let events = response.events, !events.isEmpty else { return nil }
            
            return SportGameData(
                league: sport,
                leagueName: sport.uppercased(),
                leagueAbbreviation: sport.uppercased(),
                icon: getSportIcon(for: sport),
                events: events
            )
        } catch {
            print("Error fetching \(sport) scores: \(error)")
            return nil
        }
    }
    
    private func getSportIcon(for sport: String) -> String {
        switch sport.uppercased() {
        case "NBA", "WNBA", "NCAAM": return "basketball"
        case "NFL", "NCAAF": return "football"
        case "MLB": return "baseball"
        case "NHL": return "hockey.puck"
        case "MLS": return "soccerball"
        case "PGA": return "figure.golf"
        default: return "sportscourt"
        }
    }
    
    // MARK: - Video Content Methods
    
    func fetchVideoContent() async throws -> [VideoCategory] {
        
        let watchAPIURL = "https://watch.product.api.espn.com/api/product/v3/watchespn/web/home?lang=en&features=continueWatching,flagship,pbov7,high-volume-row,watch-web-redesign,imageRatio58x13,promoTiles,openAuthz,video-header,explore-row,button-service,inline-header&headerBgImageWidth=1280&countryCode=US&tz=UTC-0400"
        
        guard let url = URL(string: watchAPIURL) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            
            // Parse the Watch API response on a background queue to avoid blocking main thread
            let response = await withCheckedContinuation { continuation in
                Task.detached(priority: .userInitiated) {
                    let result = ESPNWatchAPIParser.parseResponse(from: data)
                    continuation.resume(returning: result)
                }
            }
            
            guard let response = response else {
                throw APIError.invalidResponse
            }
            
            guard let page = response.page,
                  let buckets = page.buckets else {
                return []
            }
            
            
            // Convert buckets to video categories
            var categories: [VideoCategory] = []
            
            for (bucketIndex, bucket) in buckets.enumerated() {
                guard let bucketName = bucket.name,
                      let contents = bucket.contents,
                      !contents.isEmpty else {
                    continue
                }
                
                // Convert content items to video items (optimized sequential processing)
                let videos = contents.compactMap { content in
                    ESPNWatchAPIParser.convertToVideoItem(content)
                }
                
                if !videos.isEmpty {
                    let category = VideoCategory(
                        name: bucketName,
                        description: bucketName,
                        videos: videos,
                        isLive: videos.contains { $0.isLive },
                        priority: bucketIndex,  // Use original bucket index
                        tags: bucket.tags ?? [],
                        showTitle: !(bucket.tags?.contains("inline-header") == true)
                    )
                    categories.append(category)
                }
            }
            
            return categories
            
        } catch {
            // If network request fails, return offline fallback content
            print("Watch API failed with error: \(error). Using offline fallback content.")
            return createOfflineVideoContent()
        }
    }
    
    // MARK: - Playback URL Resolution
    
    func resolvePlaybackURL(from apiURL: String) async throws -> String {
        guard let url = URL(string: apiURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0 // 10 second timeout
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await session.data(for: request)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let playbackState = json["playbackState"] as? [String: Any],
              let videoHref = playbackState["videoHref"] as? String else {
            throw APIError.invalidResponse
        }
        
        return videoHref
    }
    
    // MARK: - Offline Fallback Content
    
    private func createOfflineVideoContent() -> [VideoCategory] {
        let fallbackVideos = [
            VideoItem(
                title: "ESPN Network Currently Unavailable",
                description: "Check your internet connection and try again",
                thumbnailURL: nil,
                videoURL: nil,
                duration: nil,
                publishedDate: Date(),
                sport: "General",
                league: nil,
                isLive: false,
                viewCount: nil,
                tags: ["offline", "system"],
                autoplay: false,
                showMetadata: true,
                size: "md",
                type: "system",
                network: "ESPN",
                reAir: nil,
                eventName: nil,
                ratio: "16:9",
                authType: [],
                streamingURL: nil,
                contentId: "offline-1",
                isEvent: false,
                appPlayURL: nil
            ),
            VideoItem(
                title: "Offline Mode - Demo Content",
                description: "ESPN Watch will automatically reconnect when internet is available",
                thumbnailURL: nil,
                videoURL: nil,
                duration: nil,
                publishedDate: Date(),
                sport: "General",
                league: nil,
                isLive: false,
                viewCount: nil,
                tags: ["offline", "demo"],
                autoplay: false,
                showMetadata: true,
                size: "md",
                type: "system",
                network: "ESPN",
                reAir: nil,
                eventName: nil,
                ratio: "16:9",
                authType: [],
                streamingURL: nil,
                contentId: "offline-2",
                isEvent: false,
                appPlayURL: nil
            )
        ]
        
        return [
            VideoCategory(
                name: "Connection Status",
                description: "Network connectivity information",
                videos: fallbackVideos,
                isLive: false,
                priority: 0,
                tags: ["offline"],
                showTitle: true
            )
        ]
    }
}