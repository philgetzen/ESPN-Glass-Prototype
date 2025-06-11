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
        case .baseball: return .white
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
}