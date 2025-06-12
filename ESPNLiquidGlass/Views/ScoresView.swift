import SwiftUI

struct ScoresView: View {
    @State private var selectedSport: Sport = .basketball
    @State private var selectedLeague: League?
    @State private var games = Game.generateMockGames()
    @State private var topEvents: [(sport: Sport, text: String)] = [
        (.basketball, "NBA"),
        (.basketball, "WNBA"),
        (.baseball, "MLB")
    ]
    
    var filteredGames: [Game] {
        if let league = selectedLeague {
            return games.filter { $0.league.id == league.id }
        }
        return games.filter { $0.league.sport == selectedSport }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Events Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(topEvents, id: \.text) { event in
                            Button(action: {
                                selectedSport = event.sport
                                selectedLeague = League.featured.first { $0.abbreviation == event.text }
                            }) {
                                Text(event.text)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(selectedLeague?.abbreviation == event.text ? .black : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedLeague?.abbreviation == event.text ? Color.white : Color.gray.opacity(0.3)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color(UIColor.systemBackground))
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Favorites Section
                if !filteredGames.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("FAVORITES")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Text("Edit")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        // Mock favorite teams
                        VStack(spacing: 1) {
                            GameRow(game: filteredGames[0], isFavorite: true)
                            if filteredGames.count > 1 {
                                GameRow(game: filteredGames[1], isFavorite: true)
                            }
                        }
                    }
                    .background(Color(UIColor.systemBackground))
                }
                
                // League Section
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(selectedLeague?.abbreviation ?? selectedSport.rawValue.uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("See All")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    ScrollView {
                        LazyVStack(spacing: 1) {
                            ForEach(filteredGames) { game in
                                GameRow(game: game, isFavorite: false)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(Color(UIColor.systemBackground))
            }
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("ESPN_Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .medium))
                            .glowEffect(
                                color: .blue,
                                radius: 3,
                                intensity: .subtle,
                                pulsation: .none
                            )
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "gear")
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
        }
    }
}

struct GameRow: View {
    let game: Game
    let isFavorite: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                // Away Team
                HStack {
                    if isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                            .glowEffect(color: .yellow, radius: 3)
                    }
                    
                    Text(game.awayTeam.abbreviation)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(game.awayScore)")
                        .font(.system(size: 18, weight: game.awayScore > game.homeScore ? .bold : .regular))
                        .foregroundColor(game.awayScore > game.homeScore ? .primary : .secondary)
                }
                
                // Home Team
                HStack {
                    if isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                            .glowEffect(color: .yellow, radius: 3)
                    }
                    
                    Text(game.homeTeam.abbreviation)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(game.homeScore)")
                        .font(.system(size: 18, weight: game.homeScore > game.awayScore ? .bold : .regular))
                        .foregroundColor(game.homeScore > game.awayScore ? .primary : .secondary)
                }
            }
            
            VStack(alignment: .trailing, spacing: 4) {
                if game.status.isLive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                            .glowEffect(color: .red, radius: 4)
                        Text("LIVE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
                
                Text(game.displayTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let broadcast = game.broadcastInfo {
                    Text(broadcast)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 80)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .liquidGlassBackground(style: .thin)
        .overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            game.homeTeam.primaryColor.opacity(0.1),
                            Color.clear,
                            game.awayTeam.primaryColor.opacity(0.1)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }
}