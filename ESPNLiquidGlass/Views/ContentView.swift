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
