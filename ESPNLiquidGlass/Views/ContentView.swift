import SwiftUI

/// Root view that shows the five ESPN tabs with Apple’s stock `TabView` styling.
struct ContentView: View {
    @State private var selectedTab = 0
    @State private var colorScheme: ColorScheme? = nil

    var body: some View {
        TabView(selection: $selectedTab) {

                HomeView(colorScheme: $colorScheme)
                    .tabItem { Label("Home", systemImage: "house") }
                    .tag(0)

                ScoresView(colorScheme: $colorScheme)
                    .tabItem { Label("Scores", systemImage: "sportscourt") }
                    .tag(1)

                WatchView(colorScheme: $colorScheme)
                    .tabItem { Label("Watch", systemImage: "play.rectangle") }
                    .tag(2)

                ESPNPlusView(colorScheme: $colorScheme)
                    .tabItem { Label("ESPN+", systemImage: "plus.rectangle") }
                    .tag(3)

                MoreView(colorScheme: $colorScheme)
                    .tabItem { Label("More", systemImage: "ellipsis") }
                    .tag(4)
        }
        .preferredColorScheme(colorScheme)
        .onAppear {
            configureTabBarAppearance()
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        // Always use the app's color scheme, not the individual view's
        let effectiveColorScheme = colorScheme ?? .light
        
        // Set background based on app color scheme
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        
        // Configure blur effect based on app color scheme
        appearance.backgroundEffect = UIBlurEffect(style: effectiveColorScheme == .dark ? .systemMaterialDark : .systemMaterialLight)
        
        // Configure selected item color (ESPN red)
        let espnRed = UIColor(red: 0.89, green: 0.094, blue: 0.216, alpha: 1.0) // #E31837
        appearance.stackedLayoutAppearance.selected.iconColor = espnRed
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: espnRed]
        appearance.inlineLayoutAppearance.selected.iconColor = espnRed
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: espnRed]
        appearance.compactInlineLayoutAppearance.selected.iconColor = espnRed
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: espnRed]
        
        // Set the appearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    ContentView()
        .preferredColorScheme(.light)
}
