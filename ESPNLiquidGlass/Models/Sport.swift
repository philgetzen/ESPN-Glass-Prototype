import Foundation
import SwiftUI

enum Sport: String, CaseIterable, Identifiable {
    case basketball = "Basketball"
    case baseball = "Baseball"
    case football = "Football"
    case hockey = "Hockey"
    case soccer = "Soccer"
    case tennis = "Tennis"
    case golf = "Golf"
    case boxing = "Boxing"
    case cricket = "Cricket"
    case mma = "MMA"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .basketball: return "basketball.fill"
        case .baseball: return "baseball.fill"
        case .football: return "football.fill"
        case .hockey: return "hockey.puck.fill"
        case .soccer: return "soccerball"
        case .tennis: return "tennisball.fill"
        case .golf: return "figure.golf"
        case .boxing: return "figure.boxing"
        case .cricket: return "cricket.ball.fill"
        case .mma: return "figure.martial.arts"
        }
    }
    
    var color: Color {
        switch self {
        case .basketball: return .orange
        case .baseball: return .primary
        case .football: return .brown
        case .hockey: return .blue
        case .soccer: return .green
        case .tennis: return .yellow
        case .golf: return .mint
        case .boxing: return .red
        case .cricket: return .indigo
        case .mma: return .purple
        }
    }
    
    // Map ESPN API sport IDs to our Sport enum
    static func fromAPIId(_ sportId: Int) -> Sport? {
        switch sportId {
        case 40: return .basketball  // NBA
        case 46: return .basketball  // NCAAM
        case 10: return .baseball    // MLB
        case 20: return .football    // NFL
        case 23: return .football    // NCAAF
        case 90: return .hockey      // NHL
        case 600: return .soccer     // Soccer
        case 850: return .tennis     // Tennis
        case 1100: return .golf      // Golf
        case 32: return .boxing      // Boxing
        case 3400: return .mma       // MMA
        default: return nil
        }
    }
}