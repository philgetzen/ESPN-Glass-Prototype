import SwiftUI

struct ScoresView: View {
    @State private var sportsData: [SportGameData] = []
    @State private var selectedDate = Date()
    @State private var selectedSports: Set<String> = ["Top Events"]
    @State private var isLoading = false
    @State private var showSettings = false
    @Binding var colorScheme: ColorScheme?
    
    private let apiService = ESPNAPIService.shared
    
    // Available sports filters - dynamically ordered based on game availability
    private var availableSports: [String] {
        let baseSports = ["NBA", "WNBA", "PGA", "MLB", "NHL", "NCAAF", "NCAAM", "MLS"]
        
        // Separate sports with games from those without
        let sportsWithGames = baseSports.filter { sport in
            sportsData.contains { $0.leagueAbbreviation == sport }
        }
        let sportsWithoutGames = baseSports.filter { sport in
            !sportsData.contains { $0.leagueAbbreviation == sport }
        }
        
        // Return "Top Events" first, then sports with games, then sports without games
        return ["Top Events"] + sportsWithGames + sportsWithoutGames
    }
    
    // Generate dates for the week view
    private var weekDates: [Date] {
        let calendar = Calendar.current
        return (-3...3).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: Date())
        }
    }
    
    var filteredSportsData: [SportGameData] {
        if selectedSports.contains("Top Events") {
            // Show all sports with games
            return sportsData
        } else {
            // Filter by selected sports
            return sportsData.filter { sportData in
                selectedSports.contains(sportData.leagueAbbreviation)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Date slider
                dateSlider
                
                // Sport filter toggles
                sportToggles
                
                Divider()
                
                // Games list
                if isLoading {
                    Spacer()
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredSportsData.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "sportscourt")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("No games scheduled")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(filteredSportsData, id: \.league) { sportData in
                                GamesList(sportData: sportData)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Scores")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.primary)
                        }
                        
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gear")
                                .foregroundColor(.primary)
                                .font(.system(size: 16, weight: .medium))
                                .glowEffect(
                                    color: .gray,
                                    radius: 3,
                                    intensity: .subtle,
                                    pulsation: .none
                                )
                        }
                    }
                }
            }
            .task {
                await loadScores()
            }
            .refreshable {
                await loadScores()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(colorScheme: $colorScheme)
                    .preferredColorScheme(colorScheme)
            }
        }
    }
    
    private var dateSlider: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(weekDates, id: \.self) { date in
                        DateButton(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                            .id(date)
                            .onTapGesture {
                                selectedDate = date
                                Task {
                                    await loadScores()
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color(UIColor.systemBackground))
            .onAppear {
                proxy.scrollTo(selectedDate, anchor: .center)
            }
        }
    }
    
    private var sportToggles: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(availableSports, id: \.self) { sport in
                    SportToggle(
                        sport: sport,
                        isSelected: selectedSports.contains(sport),
                        hasGames: sportsData.contains { $0.leagueAbbreviation == sport }
                    ) {
                        toggleSport(sport)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .frame(height: 44)
        .fixedSize(horizontal: false, vertical: true)
        .clipped()
        .scrollDisabled(false)
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .background(Color(UIColor.systemBackground))
    }
    
    private func toggleSport(_ sport: String) {
        if sport == "Top Events" {
            selectedSports = ["Top Events"]
        } else {
            selectedSports.remove("Top Events")
            if selectedSports.contains(sport) {
                selectedSports.remove(sport)
                if selectedSports.isEmpty {
                    selectedSports.insert("Top Events")
                }
            } else {
                selectedSports.insert(sport)
            }
        }
    }
    
    private func loadScores() async {
        isLoading = true
        
        let sports = selectedSports.contains("Top Events") ? nil : Array(selectedSports)
        let data = await apiService.fetchScoresForDate(selectedDate, sports: sports)
        
        await MainActor.run {
            self.sportsData = data
            self.isLoading = false
        }
    }
}

struct DateButton: View {
    let date: Date
    let isSelected: Bool
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayOfWeek)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : (isToday ? .red : .secondary))
            
            Text(dayNumber)
                .font(.title3)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(width: 50, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.red : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday && !isSelected ? Color.red : Color.clear, lineWidth: 1)
        )
    }
}

struct SportToggle: View {
    let sport: String
    let isSelected: Bool
    let hasGames: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: sportIcon)
                    .font(.caption)
                Text(sport)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .black : (hasGames ? .primary : .secondary))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.yellow : Color.gray.opacity(0.2))
            )
            .opacity(hasGames || sport == "Top Events" ? 1.0 : 0.6)
        }
        .disabled(!hasGames && sport != "Top Events")
    }
    
    private var sportIcon: String {
        switch sport {
        case "NBA", "WNBA", "NCAAM": return "basketball"
        case "MLB": return "baseball"
        case "NHL": return "hockey.puck"
        case "NCAAF", "NFL": return "football"
        case "PGA": return "flag"
        case "MLS": return "soccerball"
        default: return "star"
        }
    }
}

struct GamesList: View {
    let sportData: SportGameData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            HStack {
                Text(sportData.leagueName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Games List
            VStack(spacing: 12) {
                ForEach(sportData.events, id: \.id) { event in
                    GameCard(event: event, league: sportData.leagueAbbreviation)
                }
            }
            .padding(.horizontal)
        }
    }
}

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
        if let status = event.status {
            if event.isLive {
                // Show detailed live status with period/quarter info
                if let displayClock = status.displayClock, !displayClock.isEmpty {
                    if let period = status.period, period > 0 {
                        let periodText = getPeriodText(for: league, period: period)
                        return "\(displayClock) \(periodText)"
                    }
                    return displayClock
                }
                return "LIVE"
            } else if event.isUpcoming {
                return formatGameTime()
            } else if event.isFinal {
                // Check for overtime or specific final status
                if let detail = status.type?.detail, detail.contains("OT") {
                    return detail
                } else if let shortDetail = status.type?.shortDetail, shortDetail != "Final" {
                    return shortDetail
                }
                return "Final"
            }
        }
        return formatGameTime()
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
        
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return "" }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        return timeFormatter.string(from: date)
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
        VStack(spacing: 0) {
            // Game status bar
            HStack {
                if event.isLive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                        Text("LIVE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        if statusText != "LIVE" {
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(statusText)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    }
                } else if event.isUpcoming {
                    HStack(spacing: 4) {
                        Text("UPCOMING")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(statusText)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else if event.isFinal {
                    HStack(spacing: 4) {
                        Text(statusText)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        // Show replay indicator for recent games
                        if isRecentGame() {
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("REPLAY")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }
                } else {
                    Text(statusText)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            
            // Teams and scores
            VStack(spacing: 12) {
                // Away team
                teamRow(team: awayTeam, isWinner: awayTeam?.winner == true)
                
                // Home team  
                teamRow(team: homeTeam, isWinner: homeTeam?.winner == true)
            }
            .padding(16)
            .background(Color(UIColor.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func teamRow(team: ESPNEvent.Competition.Competitor?, isWinner: Bool) -> some View {
        HStack(spacing: 12) {
            // Team logo with fallback
            Group {
                if let logoURL = team?.team?.logo, let url = URL(string: logoURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Circle()
                            .fill(teamColor(team?.team?.color))
                            .overlay(
                                Text(team?.team?.abbreviation?.prefix(2) ?? "")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    }
                } else {
                    Circle()
                        .fill(teamColor(team?.team?.color))
                        .overlay(
                            Text(team?.team?.abbreviation?.prefix(2) ?? "")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                }
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            
            // Team name
            VStack(alignment: .leading, spacing: 2) {
                Text(team?.team?.shortDisplayName ?? team?.team?.displayName ?? "TBD")
                    .font(.system(size: 16, weight: isWinner ? .semibold : .regular))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let record = team?.records?.first?.summary {
                    Text(record)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Ranking if available
            if let rank = team?.curatedRank?.current {
                Text("\(rank)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.gray.opacity(0.2)))
            }
            
            // Score
            Text(team?.score ?? "-")
                .font(.title2)
                .fontWeight(isWinner ? .bold : .regular)
                .foregroundColor(isWinner ? .primary : .secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }
    
    private func teamColor(_ colorString: String?) -> Color {
        guard let colorString = colorString else { return .gray }
        return Color(hex: colorString) ?? .gray
    }
    
}

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

#Preview {
    ScoresView(colorScheme: .constant(.dark))
}

#Preview("Date Button") {
    DateButton(date: Date(), isSelected: true)
        .padding()
        .background(Color(UIColor.systemBackground))
}

#Preview("Sport Toggle") {
    HStack {
        SportToggle(sport: "NBA", isSelected: true, hasGames: true) {}
        SportToggle(sport: "NFL", isSelected: false, hasGames: true) {}
        SportToggle(sport: "MLB", isSelected: false, hasGames: false) {}
    }
    .padding()
    .background(Color(UIColor.systemBackground))
}

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
