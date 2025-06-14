import SwiftUI

struct ScoresView: View {
    @State private var viewState = ScoresViewState.loading
    @State private var selectedDate = Date()
    @State private var selectedSports: Set<String> = ["Top Events"]
    @State private var showSettings = false
    @State private var currentWeekOffset = 0
    @Binding var colorScheme: ColorScheme?
    @Environment(\.colorScheme) private var environmentColorScheme
    
    private let apiService = ESPNAPIService.shared
    
    // Adaptive overlay color for light/dark mode
    private var overlayColor: Color {
        let currentScheme = colorScheme ?? environmentColorScheme
        return currentScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.7)
    }
    
    // Available sports filters - dynamically ordered based on game availability
    private var availableSports: [String] {
        let baseSports = ["NBA", "WNBA", "PGA", "MLB", "NHL", "NCAAF", "NCAAM", "MLS"]
        
        guard case .loaded(let sportsData) = viewState else {
            return ["Top Events"] + baseSports
        }
        
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
        guard case .loaded(let sportsData) = viewState else {
            return []
        }
        
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
                // Date slider and sport toggles with frosted glass effect
                VStack(spacing: 0) {
                    // Date slider
                    dateSlider
                    
                    // Sport filter toggles
                    sportToggles
                }
                .background(overlayColor)
                
                // Games list
                Group {
                    switch viewState {
                    case .loading:
                        LoadingView()
                        
                    case .loaded(_):
                        if filteredSportsData.isEmpty {
                            EmptyStateView(
                                icon: "sportscourt",
                                title: "No games scheduled",
                                message: selectedSports.contains("Top Events") 
                                    ? "No games scheduled for this date"
                                    : "No games for selected sports"
                            )
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
                            .scrollContentBackground(.hidden)
                        }
                        
                    case .error(let errorMessage):
                        ErrorView(error: errorMessage, retry: loadScores)
                        
                    case .empty:
                        EmptyStateView(
                            icon: "sportscourt",
                            title: "No Games Today",
                            message: "Check back later or try a different date"
                        )
                    }
                }
            }
            .adaptiveBackground()
            .navigationTitle("Scores")
            .navigationBarTitleDisplayMode(.inline)
            .espnToolbar(onSettingsTap: { showSettings = true })
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
                        hasGames: {
                            if case .loaded(let data) = viewState {
                                return data.contains { $0.leagueAbbreviation == sport }
                            }
                            return false
                        }()
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
        await MainActor.run {
            viewState = .loading
        }
        
        let sports = selectedSports.contains("Top Events") ? ["NBA", "WNBA", "PGA", "MLB", "NHL", "NCAAF", "NCAAM", "MLS"] : Array(selectedSports)
        let data = await apiService.fetchScoresForDate(selectedDate, sports: sports)
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                if data.isEmpty {
                    viewState = .empty
                } else {
                    viewState = .loaded(data)
                }
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
            }
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.15), lineWidth: 1)
            )
            .liquidGlassCard(cornerRadius: 16, density: .medium)
            .padding(.horizontal, 16)
        }
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

