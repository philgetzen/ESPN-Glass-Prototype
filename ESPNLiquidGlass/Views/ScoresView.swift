import SwiftUI

struct ScoresView: View {
    @State private var sportsData: [SportGameData] = []
    @State private var selectedDate = Date()
    @State private var selectedSports: Set<String> = ["Top Events"]
    @State private var isLoading = false
    @State private var showSettings = false
    @State private var currentWeekOffset = 0
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
                    List {
                        ForEach(filteredSportsData, id: \.league) { sportData in
                            GamesList(sportData: sportData)
                                .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .background(
                        Color(UIColor.systemGroupedBackground)
                            .glowEffect(
                                color: .gray,
                                radius: 5,
                                intensity: .subtle,
                                pulsation: .none
                            )
                    )
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
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
        HStack(spacing: 0) {
            // Left arrow with glass gradient
            Button(action: {
                withAnimation(.easeInOut(duration: 0.8)) {
                    currentWeekOffset -= 1
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary.opacity(0.9))
                    .frame(width: 44, height: 44)
            }
            
            // TabView for smooth horizontal sliding
            TabView(selection: $currentWeekOffset) {
                ForEach(-10...10, id: \.self) { weekOffset in
                    weekView(for: weekOffset)
                        .tag(weekOffset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .animation(.easeInOut(duration: 0.6), value: currentWeekOffset)
            .onChange(of: currentWeekOffset) { oldOffset, newOffset in
                updateSelectedDateForCurrentWeek()
                Task {
                    await loadScores()
                }
            }
            
            // Right arrow with glass gradient
            Button(action: {
                withAnimation(.easeInOut(duration: 0.8)) {
                    currentWeekOffset += 1
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary.opacity(0.9))
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
        .overlay(alignment: .leading) {
            // Left edge glass mask
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(UIColor.systemBackground),
                            Color(UIColor.systemBackground).opacity(0.8),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 44)
                .allowsHitTesting(false) // Allow taps to pass through
        }
        .overlay(alignment: .trailing) {
            // Right edge glass mask
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color(UIColor.systemBackground).opacity(0.8),
                            Color(UIColor.systemBackground)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 44)
                .allowsHitTesting(false) // Allow taps to pass through
        }
        .onAppear {
            // Initialize with today's date centered
            initializeSelectedDate()
        }
    }
    
    private func weekView(for weekOffset: Int) -> some View {
        let weekDates = generateWeekDates(for: weekOffset)
        
        return HStack(spacing: 0) {
            ForEach(weekDates, id: \.self) { date in
                DateButton(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                    .frame(minWidth: 50, maxWidth: .infinity) // Prevent smooshing with min/max width
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedDate = date
                        }
                        Task {
                            await loadScores()
                        }
                    }
            }
        }
        .padding(.horizontal)
    }
    
    private func generateWeekDates(for weekOffset: Int) -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let baseDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today) ?? today
        
        return (-3...3).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: baseDate)
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
        
        let sports = selectedSports.contains("Top Events") ? ["NBA", "WNBA", "PGA", "MLB", "NHL", "NCAAF", "NCAAM", "MLS"] : Array(selectedSports)
        let data = await apiService.fetchScoresForDate(selectedDate, sports: sports)
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.sportsData = data
                self.isLoading = false
            }
        }
    }
    
    private func initializeSelectedDate() {
        // Start with today's date, which should be in the center of the current week
        let today = Date()
        selectedDate = today
        currentWeekOffset = 0
    }
    
    private func updateSelectedDateForCurrentWeek() {
        let calendar = Calendar.current
        let today = Date()
        
        // Calculate the new base date for the current week offset
        if let newBaseDate = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: today) {
            // Try to maintain the same day of week, or fallback to the center date
            let currentDayOfWeek = calendar.component(.weekday, from: selectedDate)
            let newBaseDayOfWeek = calendar.component(.weekday, from: newBaseDate)
            
            if let newSelectedDate = calendar.date(byAdding: .day, value: currentDayOfWeek - newBaseDayOfWeek, to: newBaseDate) {
                selectedDate = newSelectedDate
            } else {
                selectedDate = newBaseDate
            }
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
                .foregroundColor(isSelected ? .white : .secondary)
            
            Text(dayNumber)
                .font(.title3)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(width: 50, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    isSelected ? Color.red : 
                    (isToday ? Color.white.opacity(0.1) : Color.clear)
                )
                .padding(.horizontal, isToday && !isSelected ? 3 : 0)
                .glowEffect(
                    color: isSelected ? .red : .clear,
                    radius: 4,
                    intensity: isSelected ? .medium : .subtle,
                    pulsation: .none
                )
                .shadow(color: isSelected ? .red.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
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
                    .fill(isSelected ? Color.yellow : Color.gray.opacity(0.15))
                    .glowEffect(
                        color: isSelected ? .yellow : .clear,
                        radius: 3,
                        intensity: isSelected ? .medium : .subtle,
                        pulsation: .none
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
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
        VStack(spacing: 0) {
            // Section with both header and games in one rounded container
            VStack(spacing: 0) {
                // Section Header
                HStack {
                    Text(sportData.leagueAbbreviation)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary.opacity(0.8))
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("See All")
                            .font(.system(size: 13))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [
                            Color(UIColor.tertiarySystemBackground),
                            Color(UIColor.secondarySystemBackground).opacity(0.8)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.primary.opacity(0.15))
                        .shadow(color: .black.opacity(0.1), radius: 0.5, x: 0, y: 0.5),
                    alignment: .bottom
                )
                
                // Games List
                LazyVStack(spacing: 0) {
                    ForEach(sportData.events.indices, id: \.self) { index in
                        GameCard(event: sportData.events[index], league: sportData.leagueAbbreviation)
                            .id("\(sportData.league)-\(sportData.events[index].id ?? "\(index)")")
                        
                        if index < sportData.events.count - 1 {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.primary.opacity(0.12))
                                .padding(.horizontal, 16)
                                .shadow(color: .black.opacity(0.1), radius: 0.5, x: 0, y: 0.5)
                        }
                    }
                }
                .background(Color(UIColor.systemBackground))
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
                    .glowEffect(
                        color: .gray,
                        radius: 3,
                        intensity: .medium,
                        pulsation: .none
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            .padding(.horizontal, 16)
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
                        .glowEffect(
                            color: .red,
                            radius: 2,
                            intensity: .medium,
                            pulsation: .gentle
                        )
                )
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
        .background(
            Rectangle()
                .fill(Color(UIColor.systemBackground))
                .glowEffect(
                    color: event.isLive ? .red : .clear,
                    radius: 2,
                    intensity: event.isLive ? .medium : .subtle,
                    pulsation: event.isLive ? .gentle : .none
                )
        )
        .overlay(
            Rectangle()
                .fill(Color.clear)
                .background(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.02),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.1)
                    )
                )
        )
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
