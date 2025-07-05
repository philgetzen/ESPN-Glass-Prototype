import SwiftUI

struct ESPNToolbar: ToolbarContent {
    let logoType: LogoType
    let isDarkMode: Bool
    let forcesDarkIcons: Bool
    let onSearchTap: () -> Void
    let onSettingsTap: () -> Void
    
    enum LogoType {
        case roundLogo  // E_Round_Logo for Home
        case standardLogo  // ESPN_Logo for other views
    }
    
    init(
        logoType: LogoType = .standardLogo,
        isDarkMode: Bool = false,
        forcesDarkIcons: Bool = false,
        onSearchTap: @escaping () -> Void = {},
        onSettingsTap: @escaping () -> Void
    ) {
        self.logoType = logoType
        self.isDarkMode = isDarkMode
        self.forcesDarkIcons = forcesDarkIcons
        self.onSearchTap = onSearchTap
        self.onSettingsTap = onSettingsTap
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Group {
                switch logoType {
                case .roundLogo:
                    Image("E_Round_Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44, alignment: .center)
                case .standardLogo:
                    Image("ESPN_Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 24)
                        .clipped()
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
                if #available(iOS 18.0, *) {
                    // iOS 26 with Liquid Glass buttons
                    Button(action: onSearchTap) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(forcesDarkIcons ? .black : (isDarkMode ? .white : .primary))
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(GlassButtonStyle())
                    
                    Button(action: onSettingsTap) {
                        Image(systemName: "gear")
                            .foregroundColor(forcesDarkIcons ? .black : (isDarkMode ? .white : .primary))
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(GlassButtonStyle())
                } else {
                    // Fallback for older iOS versions
                    Button(action: onSearchTap) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(forcesDarkIcons ? .black : (isDarkMode ? .white : .primary))
                            .font(.system(size: 16, weight: .medium))
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .blue.opacity(0.3), radius: 3)
                            )
                    }
                    
                    Button(action: onSettingsTap) {
                        Image(systemName: "gear")
                            .foregroundColor(forcesDarkIcons ? .black : (isDarkMode ? .white : .primary))
                            .font(.system(size: 16, weight: .medium))
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .gray.opacity(0.3), radius: 3)
                            )
                    }
                }
            }
        }
    }
}

// MARK: - Toolbar Configuration Helper
extension View {
    /// Apply ESPN toolbar with Liquid Glass effects
    func espnToolbar(
        logoType: ESPNToolbar.LogoType = .standardLogo,
        isDarkMode: Bool = false,
        forcesDarkIcons: Bool = false,
        forceDarkToolbar: Bool = true,
        onSearchTap: @escaping () -> Void = {},
        onSettingsTap: @escaping () -> Void
    ) -> some View {
        self
            .toolbar {
                ESPNToolbar(
                    logoType: logoType,
                    isDarkMode: isDarkMode,
                    forcesDarkIcons: forcesDarkIcons,
                    onSearchTap: onSearchTap,
                    onSettingsTap: onSettingsTap
                )
            }
            .toolbarColorScheme(forceDarkToolbar ? .dark : (isDarkMode ? .dark : .light), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }
    
    /// Apply ESPN navigation bar styling with iOS 26 Liquid Glass
    func espnNavigationBarStyle() -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }
}

// MARK: - Preview Helpers
#Preview("ESPN Toolbar - Light Mode") {
    NavigationStack {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<10) { i in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 100)
                        .overlay(Text("Content \(i)"))
                }
            }
            .padding()
        }
        .navigationTitle("ESPN")
        .espnToolbar(
            logoType: .standardLogo,
            isDarkMode: false,
            onSettingsTap: { print("Settings tapped") }
        )
    }
}

#Preview("ESPN Toolbar - Dark Mode") {
    NavigationStack {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<10) { i in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 100)
                        .overlay(Text("Content \(i)"))
                }
            }
            .padding()
        }
        .navigationTitle("ESPN")
        .espnToolbar(
            logoType: .standardLogo,
            isDarkMode: true,
            onSettingsTap: { print("Settings tapped") }
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("ESPN Toolbar - Home View") {
    NavigationStack {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<10) { i in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 100)
                        .overlay(Text("Content \(i)"))
                }
            }
            .padding()
        }
        .navigationTitle("Home")
        .espnToolbar(
            logoType: .roundLogo,
            isDarkMode: false,
            onSettingsTap: { print("Settings tapped") }
        )
    }
}
