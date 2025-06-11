import Foundation
import SwiftUI

enum GameStatus {
    case scheduled
    case live(period: String, timeRemaining: String)
    case final
    case postponed
    
    var displayText: String {
        switch self {
        case .scheduled:
            return "Scheduled"
        case .live(let period, let time):
            return "\(period) - \(time)"
        case .final:
            return "Final"
        case .postponed:
            return "Postponed"
        }
    }
    
    var isLive: Bool {
        if case .live = self {
            return true
        }
        return false
    }
}

struct Game: Identifiable {
    let id = UUID()
    let homeTeam: Team
    let awayTeam: Team
    let homeScore: Int
    let awayScore: Int
    let status: GameStatus
    let startTime: Date
    let league: League
    let venue: String?
    let broadcastInfo: String?
    let attendance: Int?
    
    var winningTeam: Team? {
        guard case .final = status else { return nil }
        if homeScore > awayScore {
            return homeTeam
        } else if awayScore > homeScore {
            return awayTeam
        }
        return nil
    }
    
    var displayTime: String {
        switch status {
        case .scheduled:
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: startTime)
        case .live(_, _):
            return status.displayText
        case .final:
            return "Final"
        case .postponed:
            return "PPD"
        }
    }
}

extension Game {
    static func generateMockGames() -> [Game] {
        var games: [Game] = []
        
        // NBA Games
        games.append(Game(
            homeTeam: Team.mockNBATeams[0],
            awayTeam: Team.mockNBATeams[1],
            homeScore: 112,
            awayScore: 108,
            status: .final,
            startTime: Date(),
            league: League.featured[0],
            venue: "Crypto.com Arena",
            broadcastInfo: "ESPN",
            attendance: 18997
        ))
        
        games.append(Game(
            homeTeam: Team.mockNBATeams[3],
            awayTeam: Team.mockNBATeams[4],
            homeScore: 68,
            awayScore: 72,
            status: .live(period: "3rd", timeRemaining: "5:30"),
            startTime: Date(),
            league: League.featured[0],
            venue: "Paycom Center",
            broadcastInfo: "ABC",
            attendance: 18203
        ))
        
        // WNBA Games
        games.append(Game(
            homeTeam: Team.mockWNBATeams[0],
            awayTeam: Team.mockWNBATeams[1],
            homeScore: 0,
            awayScore: 0,
            status: .scheduled,
            startTime: Date().addingTimeInterval(3600 * 3),
            league: League.featured[1],
            venue: "Target Center",
            broadcastInfo: "WNBA League Pass",
            attendance: nil
        ))
        
        games.append(Game(
            homeTeam: Team.mockWNBATeams[2],
            awayTeam: Team.mockWNBATeams[3],
            homeScore: 78,
            awayScore: 85,
            status: .final,
            startTime: Date(),
            league: League.featured[1],
            venue: "Crypto.com Arena",
            broadcastInfo: "CBS Sports Network",
            attendance: 10245
        ))
        
        // MLB Games
        games.append(Game(
            homeTeam: Team.mockMLBTeams[0],
            awayTeam: Team.mockMLBTeams[1],
            homeScore: 2,
            awayScore: 4,
            status: .live(period: "Top 7th", timeRemaining: "1 Out"),
            startTime: Date(),
            league: League.featured[2],
            venue: "loanDepot park",
            broadcastInfo: "MLB.TV",
            attendance: 12453
        ))
        
        games.append(Game(
            homeTeam: Team.mockMLBTeams[2],
            awayTeam: Team.mockMLBTeams[3],
            homeScore: 1,
            awayScore: 6,
            status: .live(period: "Bot 5th", timeRemaining: "2 Outs"),
            startTime: Date(),
            league: League.featured[2],
            venue: "Wrigley Field",
            broadcastInfo: "MLB Network",
            attendance: 38762
        ))
        
        games.append(Game(
            homeTeam: Team.mockMLBTeams[4],
            awayTeam: Team.mockMLBTeams[5],
            homeScore: 1,
            awayScore: 7,
            status: .live(period: "Bot 8th", timeRemaining: "0 Outs"),
            startTime: Date(),
            league: League.featured[2],
            venue: "Great American Ball Park",
            broadcastInfo: "Apple TV+",
            attendance: 27893
        ))
        
        games.append(Game(
            homeTeam: Team.mockMLBTeams[6],
            awayTeam: Team.mockMLBTeams[7],
            homeScore: 2,
            awayScore: 4,
            status: .live(period: "Top 2nd", timeRemaining: "1 Out"),
            startTime: Date(),
            league: League.featured[2],
            venue: "Truist Park",
            broadcastInfo: "MLB.TV",
            attendance: 39283
        ))
        
        games.append(Game(
            homeTeam: Team.mockMLBTeams[8],
            awayTeam: Team.mockMLBTeams[9],
            homeScore: 0,
            awayScore: 1,
            status: .live(period: "End 1st", timeRemaining: ""),
            startTime: Date(),
            league: League.featured[2],
            venue: "Rogers Centre",
            broadcastInfo: "Sportsnet",
            attendance: 42134
        ))
        
        return games
    }
}