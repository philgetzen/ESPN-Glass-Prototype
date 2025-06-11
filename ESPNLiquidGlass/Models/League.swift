import Foundation
import SwiftUI

struct League: Identifiable {
    let id = UUID()
    let name: String
    let abbreviation: String
    let sport: Sport
    let logoName: String?
    let color: Color
    
    static let featured: [League] = [
        League(name: "National Basketball Association", abbreviation: "NBA", sport: .basketball, logoName: "nba", color: .orange),
        League(name: "Women's National Basketball Association", abbreviation: "WNBA", sport: .basketball, logoName: "wnba", color: .orange),
        League(name: "Major League Baseball", abbreviation: "MLB", sport: .baseball, logoName: "mlb", color: .blue),
        League(name: "National Football League", abbreviation: "NFL", sport: .football, logoName: "nfl", color: .blue),
        League(name: "National Hockey League", abbreviation: "NHL", sport: .hockey, logoName: "nhl", color: .black),
        League(name: "Premier League", abbreviation: "EPL", sport: .soccer, logoName: "epl", color: .purple),
        League(name: "UEFA Champions League", abbreviation: "UCL", sport: .soccer, logoName: "ucl", color: .blue),
        League(name: "Professional Golfers Association", abbreviation: "PGA", sport: .golf, logoName: "pga", color: .blue),
        League(name: "Australian Open", abbreviation: "AO", sport: .tennis, logoName: "ao", color: .blue),
        League(name: "Ultimate Fighting Championship", abbreviation: "UFC", sport: .mma, logoName: "ufc", color: .red)
    ]
}