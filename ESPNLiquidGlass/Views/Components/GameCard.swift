import SwiftUI

struct GameCard: View {
    let event: ESPNEvent
    let league: String
    
    private var competition: ESPNEvent.Competition? {
        event.competitions?.first
    }
    
    private var awayTeam: ESPNEvent.Competition.Competitor? {
        competition?.competitors?.first { $0.homeAway == "away" }
    }
    
    private var homeTeam: ESPNEvent.Competition.Competitor? {
        competition?.competitors?.first { $0.homeAway == "home" }
    }
    
    private var statusText: String {
        guard let status = event.status else { return formatGameTime() }
        
        if event.isLive {
            return status.displayClock ?? "LIVE"
        } else if event.isUpcoming {
            return formatGameTime()
        } else if event.isFinal {
            return status.type?.shortDetail ?? "Final"
        }
        return formatGameTime()
    }
    
    @ViewBuilder
    private var gameStateBadge: some View {
        if event.isLive {
            Text("LIVE")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Color.red)
                )
                .shadow(color: .red.opacity(0.5), radius: 4, x: 0, y: 2)
                // Using the glowEffect from our unified glass effects
                .glowEffect(color: .red, radius: 3)
        } else {
            // Empty space to maintain layout consistency
            Color.clear
                .frame(height: 16)
        }
    }
    
    private var networkInfo: String? {
        event.competitions?.first?.broadcasts?.first?.names?.first
    }
    
    private func getPeriodText(for league: String, period: Int) -> String {
        switch league.uppercased() {
        case "NBA", "WNBA", "NCAAM", "NCAAW":
            switch period {
            case 1: return "1st"
            case 2: return "2nd" 
            case 3: return "3rd"
            case 4: return "4th"
            default: return period > 4 ? "OT\(period - 4)" : "\(period)"
            }
        case "NFL", "NCAAF":
            switch period {
            case 1: return "1st"
            case 2: return "2nd"
            case 3: return "3rd" 
            case 4: return "4th"
            default: return period > 4 ? "OT" : "\(period)"
            }
        case "NHL":
            switch period {
            case 1: return "1st"
            case 2: return "2nd"
            case 3: return "3rd"
            default: return period > 3 ? "OT" : "\(period)"
            }
        case "MLB":
            if period <= 9 {
                switch period {
                case 1: return "Top 1st"
                case 2: return "Top 2nd"
                case 3: return "Top 3rd"
                default: return "Top \(period)th"
                }
            } else {
                return "Extra"
            }
        default:
            return "\(period)"
        }
    }
    
    private func formatGameTime() -> String {
        guard let dateString = event.date else { return "" }
        
        // Use a simple DateFormatter for the ESPN format we saw in logs: 2025-06-14T00:30Z
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let date = formatter.date(from: dateString) else { return "" }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.timeZone = TimeZone.current
        let timeString = timeFormatter.string(from: date)
        
        // Remove leading zero from hour
        return timeString.replacingOccurrences(of: "^0", with: "", options: .regularExpression)
    }
    
    private func isRecentGame() -> Bool {
        guard let dateString = event.date else { return false }
        
        let formatter = ISO8601DateFormatter()
        guard let gameDate = formatter.date(from: dateString) else { return false }
        
        let now = Date()
        let hoursSinceGame = now.timeIntervalSince(gameDate) / 3600
        
        // Consider games from the last 24 hours as "recent" for replay purposes
        return hoursSinceGame >= 0 && hoursSinceGame <= 24
    }
    
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Teams and scores section
            VStack(spacing: 0) {
                // Away team
                teamRow(team: awayTeam, isWinner: awayTeam?.winner == true)
                    .padding(.vertical, 12)
                
                // Home team  
                teamRow(team: homeTeam, isWinner: homeTeam?.winner == true)
                    .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity)
            
            // Game status/time section - aligned with first team
            VStack(alignment: .trailing, spacing: 2) {
                if event.isLive {
                    // Live badge
                    gameStateBadge
                    
                    // Live status
                    Text(statusText)
                        .font(.system(size: 11))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.trailing)
                } else if event.isUpcoming {
                    // Start time
                    let gameTime = formatGameTime()
                    Text(gameTime.isEmpty ? "TBD" : gameTime)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.trailing)
                    
                    // Network if available
                    if let network = networkInfo {
                        Text(network)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                } else if event.isFinal {
                    // Final status
                    Text(statusText)
                        .font(.system(size: 11))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                    
                    // Network or replay indicator for recent games
                    if isRecentGame() {
                        Text("REPLAY")
                            .font(.system(size: 9))
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.trailing)
                    } else if let network = networkInfo {
                        Text(network)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                } else {
                    // Fallback - show time regardless of status
                    let gameTime = formatGameTime()
                    Text(gameTime.isEmpty ? "TBD" : gameTime)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.trailing)
                    
                    // Network if available
                    if let network = networkInfo {
                        Text(network)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .frame(width: 80)
            .padding(.horizontal, 8)
            .padding(.top, 12) // Align with first team
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.clear)
        .espnLiveGameGlass(isLive: event.isLive)
    }
    
    private func teamRow(team: ESPNEvent.Competition.Competitor?, isWinner: Bool) -> some View {
        HStack(spacing: 8) {
            // Ranking if available
            if let rank = team?.curatedRank?.current {
                Text("\(rank)")
                    .font(.system(size: 11))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
            } else {
                Color.clear
                    .frame(width: 20)
            }
            
            // Team logo
            if let logoURL = team?.team?.logo, let url = URL(string: logoURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure(_):
                        teamLogoPlaceholder(team: team)
                    case .empty:
                        // Show placeholder immediately while loading
                        teamLogoPlaceholder(team: team)
                            .opacity(0.6)
                    @unknown default:
                        teamLogoPlaceholder(team: team)
                    }
                }
                .frame(width: 24, height: 24)
                .animation(.easeInOut(duration: 0.2), value: url)
            } else {
                teamLogoPlaceholder(team: team)
                    .frame(width: 24, height: 24)
            }
            
            // Team name and record
            VStack(alignment: .leading, spacing: 1) {
                Text(team?.team?.shortDisplayName ?? team?.team?.displayName ?? "TBD")
                    .font(.system(size: 14, weight: isWinner ? .semibold : .regular))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let record = team?.records?.first?.summary {
                    Text(record)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Score
            Text(team?.score ?? "-")
                .font(.system(size: 18, weight: isWinner ? .bold : .medium))
                .foregroundColor(isWinner ? .primary : .secondary.opacity(0.8))
                .frame(minWidth: 35, alignment: .trailing)
                .shadow(color: isWinner ? .black.opacity(0.1) : .clear, radius: 1, x: 0, y: 1)
        }
    }
    
    private func teamColor(_ colorString: String?) -> Color {
        guard let colorString = colorString else { return .gray }
        return Color(hex: colorString) ?? .gray
    }
    
    private func teamLogoPlaceholder(team: ESPNEvent.Competition.Competitor?) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(
                LinearGradient(
                    colors: [
                        teamColor(team?.team?.color),
                        teamColor(team?.team?.color).opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Text(team?.team?.abbreviation?.prefix(2) ?? "")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
    }
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Previews
#Preview("Game Card - Final") {
    GameCard(
        event: ESPNEvent(
            id: "1",
            uid: "1",
            date: "2024-12-06T20:00:00Z",
            name: "Lakers vs Warriors",
            shortName: "LAL vs GSW",
            season: nil,
            competitions: [
                ESPNEvent.Competition(
                    id: "1",
                    uid: "1",
                    date: "2024-12-06T20:00:00Z",
                    timeValid: true,
                    neutralSite: false,
                    conferenceCompetition: false,
                    boxscoreAvailable: true,
                    commentaryAvailable: true,
                    liveAvailable: true,
                    onWatchESPN: false,
                    recent: true,
                    competitors: [
                        ESPNEvent.Competition.Competitor(
                            id: "1",
                            uid: "1",
                            type: "team",
                            order: 1,
                            homeAway: "away",
                            winner: false,
                            team: ESPNEvent.Competition.Competitor.TeamInfo(
                                id: "1",
                                uid: "1",
                                location: "Los Angeles",
                                name: "Lakers",
                                abbreviation: "LAL",
                                displayName: "Los Angeles Lakers",
                                shortDisplayName: "Lakers",
                                color: "552583",
                                alternateColor: "FDB927",
                                isActive: true,
                                logo: "https://a.espncdn.com/i/teamlogos/nba/500/lal.png",
                                links: nil
                            ),
                            score: "108",
                            linescores: nil,
                            statistics: nil,
                            leaders: nil,
                            curatedRank: nil,
                            records: [
                                ESPNEvent.Competition.Competitor.Record(
                                    name: "overall",
                                    abbreviation: "Total",
                                    type: "total",
                                    summary: "15-12"
                                )
                            ]
                        ),
                        ESPNEvent.Competition.Competitor(
                            id: "2",
                            uid: "2",
                            type: "team",
                            order: 2,
                            homeAway: "home",
                            winner: true,
                            team: ESPNEvent.Competition.Competitor.TeamInfo(
                                id: "2",
                                uid: "2",
                                location: "Golden State",
                                name: "Warriors",
                                abbreviation: "GSW",
                                displayName: "Golden State Warriors",
                                shortDisplayName: "Warriors",
                                color: "1D428A",
                                alternateColor: "FFC72C",
                                isActive: true,
                                logo: "https://a.espncdn.com/i/teamlogos/nba/500/gs.png",
                                links: nil
                            ),
                            score: "115",
                            linescores: nil,
                            statistics: nil,
                            leaders: nil,
                            curatedRank: nil,
                            records: [
                                ESPNEvent.Competition.Competitor.Record(
                                    name: "overall",
                                    abbreviation: "Total",
                                    type: "total",
                                    summary: "18-9"
                                )
                            ]
                        )
                    ],
                    notes: nil,
                    situation: nil,
                    status: ESPNGameStatus(
                        clock: 0,
                        displayClock: "Final",
                        period: 4,
                        type: ESPNGameStatus.StatusType(
                            id: "3",
                            name: "Final",
                            state: "post",
                            completed: true,
                            description: "Final",
                            detail: "Final",
                            shortDetail: "Final"
                        )
                    ),
                    broadcasts: nil,
                    leaders: nil,
                    format: nil,
                    startDate: nil,
                    geoBroadcasts: nil,
                    headlines: nil
                )
            ],
            status: ESPNGameStatus(
                clock: 0,
                displayClock: "Final",
                period: 4,
                type: ESPNGameStatus.StatusType(
                    id: "3",
                    name: "Final",
                    state: "post",
                    completed: true,
                    description: "Final",
                    detail: "Final",
                    shortDetail: "Final"
                )
            ),
            venue: nil
        ),
        league: "NBA"
    )
    .padding()
    .background(Color(UIColor.systemBackground))
}

#Preview("Game Card - Live") {
    GameCard(
        event: ESPNEvent(
            id: "2",
            uid: "2",
            date: Date().addingTimeInterval(-3600).ISO8601Format(),
            name: "Celtics vs Heat",
            shortName: "BOS vs MIA",
            season: nil,
            competitions: [
                ESPNEvent.Competition(
                    id: "2",
                    uid: "2",
                    date: Date().addingTimeInterval(-3600).ISO8601Format(),
                    timeValid: true,
                    neutralSite: false,
                    conferenceCompetition: false,
                    boxscoreAvailable: true,
                    commentaryAvailable: true,
                    liveAvailable: true,
                    onWatchESPN: false,
                    recent: true,
                    competitors: [
                        ESPNEvent.Competition.Competitor(
                            id: "3",
                            uid: "3",
                            type: "team",
                            order: 1,
                            homeAway: "away",
                            winner: false,
                            team: ESPNEvent.Competition.Competitor.TeamInfo(
                                id: "3",
                                uid: "3",
                                location: "Boston",
                                name: "Celtics",
                                abbreviation: "BOS",
                                displayName: "Boston Celtics",
                                shortDisplayName: "Celtics",
                                color: "007A33",
                                alternateColor: "BA9653",
                                isActive: true,
                                logo: "https://a.espncdn.com/i/teamlogos/nba/500/bos.png",
                                links: nil
                            ),
                            score: "98",
                            linescores: nil,
                            statistics: nil,
                            leaders: nil,
                            curatedRank: nil,
                            records: [
                                ESPNEvent.Competition.Competitor.Record(
                                    name: "overall",
                                    abbreviation: "Total",
                                    type: "total",
                                    summary: "22-6"
                                )
                            ]
                        ),
                        ESPNEvent.Competition.Competitor(
                            id: "4",
                            uid: "4",
                            type: "team",
                            order: 2,
                            homeAway: "home",
                            winner: true,
                            team: ESPNEvent.Competition.Competitor.TeamInfo(
                                id: "4",
                                uid: "4",
                                location: "Miami",
                                name: "Heat",
                                abbreviation: "MIA",
                                displayName: "Miami Heat",
                                shortDisplayName: "Heat",
                                color: "98002E",
                                alternateColor: "F9A01B",
                                isActive: true,
                                logo: "https://a.espncdn.com/i/teamlogos/nba/500/mia.png",
                                links: nil
                            ),
                            score: "102",
                            linescores: nil,
                            statistics: nil,
                            leaders: nil,
                            curatedRank: nil,
                            records: [
                                ESPNEvent.Competition.Competitor.Record(
                                    name: "overall",
                                    abbreviation: "Total",
                                    type: "total",
                                    summary: "13-13"
                                )
                            ]
                        )
                    ],
                    notes: nil,
                    situation: nil,
                    status: ESPNGameStatus(
                        clock: 720.0,
                        displayClock: "7:26",
                        period: 3,
                        type: ESPNGameStatus.StatusType(
                            id: "2",
                            name: "In Progress",
                            state: "in",
                            completed: false,
                            description: "In Progress",
                            detail: "7:26 - 3rd Quarter",
                            shortDetail: "7:26 - 3rd"
                        )
                    ),
                    broadcasts: nil,
                    leaders: nil,
                    format: nil,
                    startDate: nil,
                    geoBroadcasts: nil,
                    headlines: nil
                )
            ],
            status: ESPNGameStatus(
                clock: 720.0,
                displayClock: "7:26",
                period: 3,
                type: ESPNGameStatus.StatusType(
                    id: "2",
                    name: "In Progress",
                    state: "in",
                    completed: false,
                    description: "In Progress",
                    detail: "7:26 - 3rd Quarter",
                    shortDetail: "7:26 - 3rd"
                )
            ),
            venue: nil
        ),
        league: "NBA"
    )
    .padding()
    .background(Color(UIColor.systemBackground))
}
