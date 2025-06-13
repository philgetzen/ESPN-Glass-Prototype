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
}

