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
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 44, alignment: .center)
                case .standardLogo:
                    Image("ESPN_Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                        .clipped()
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
                Button(action: onSearchTap) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(forcesDarkIcons ? .black : (isDarkMode ? .white : .primary))
                        .font(.system(size: 16, weight: .medium))
                        .glowEffect(
                            color: .blue,
                            radius: 3,
                            intensity: .subtle,
                            pulsation: .none
                        )
                }
                
                Button(action: onSettingsTap) {
                    Image(systemName: "gear")
                        .foregroundColor(forcesDarkIcons ? .black : (isDarkMode ? .white : .primary))
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
}

// MARK: - Toolbar Configuration Helper
extension View {
    func espnToolbar(
        logoType: ESPNToolbar.LogoType = .standardLogo,
        isDarkMode: Bool = false,
        forcesDarkIcons: Bool = false,
        onSearchTap: @escaping () -> Void = {},
        onSettingsTap: @escaping () -> Void
    ) -> some View {
        self.toolbar {
            ESPNToolbar(
                logoType: logoType,
                isDarkMode: isDarkMode,
                forcesDarkIcons: forcesDarkIcons,
                onSearchTap: onSearchTap,
                onSettingsTap: onSettingsTap
            )
        }
    }
}