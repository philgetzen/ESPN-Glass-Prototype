import SwiftUI

struct MoreView: View {
    @State private var selectedSportIndex = 0
    @State private var showSettings = false
    @Binding var colorScheme: ColorScheme?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Favorites Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("FAVORITES")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Text("Edit")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(Sport.allCases.prefix(8), id: \.self) { sport in
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(LinearGradient(
                                                    colors: [sport.color.opacity(0.3), sport.color.opacity(0.1)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ))
                                                .frame(width: 60, height: 60)
                                            
                                            Image(systemName: sport.iconName)
                                                .font(.title2)
                                                .foregroundColor(sport.color)
                                        }
                                        
                                        Text(sport.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // All Sports Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ALL SPORTS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ForEach(Sport.allCases, id: \.self) { sport in
                                NavigationLink(destination: SportDetailView(sport: sport)) {
                                    HStack {
                                        Image(systemName: sport.iconName)
                                            .font(.title3)
                                            .foregroundColor(sport.color)
                                            .frame(width: 30)
                                        
                                        Text(sport.rawValue)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                }
                                
                                if sport != Sport.allCases.last {
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.leading, 60)
                                }
                            }
                        }
                    }
                    
                     Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // ESPN BET Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ESPN BET SPORTSBOOK")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: EmptyView()) {
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.green)
                                
                                Text("Sports Betting")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                        
                        NavigationLink(destination: EmptyView()) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                
                                Text("About ESPN BET Sportsbook")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Settings Section
                    VStack(spacing: 0) {
                        NavigationLink(destination: EmptyView()) {
                            HStack {
                                Image(systemName: "gear")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                
                                Text("Settings")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .adaptiveBackground()
            .navigationBarTitleDisplayMode(.inline)
            .espnToolbar(onSettingsTap: { showSettings = true })
            .sheet(isPresented: $showSettings) {
                SettingsView(colorScheme: $colorScheme)
                    .preferredColorScheme(colorScheme)
            }
            .refreshableWithHaptics {
                await refreshMoreContent()
            }
        }
    }
    
    private func refreshMoreContent() async {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // In a real app, this would refresh favorites and sports data
        // For now, we just simulate the refresh
        print("Refreshed more content")
    }
}

struct SportDetailView: View {
    let sport: Sport
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: sport.iconName)
                    .font(.system(size: 80))
                    .foregroundColor(sport.color)
                    .padding(.top, 40)
                
                Text(sport.rawValue)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Latest news, scores, and highlights")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MoreView(colorScheme: .constant(.dark))
}

#Preview("Dark Mode") {
    MoreView(colorScheme: .constant(.dark))
        .preferredColorScheme(.dark)
}

#Preview("Sport Detail") {
    SportDetailView(sport: .football)
}
