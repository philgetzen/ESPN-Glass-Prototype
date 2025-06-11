import Foundation
import SwiftUI

struct Team: Identifiable {
    let id = UUID()
    let name: String
    let abbreviation: String
    let city: String
    let primaryColor: Color
    let secondaryColor: Color
    let logoName: String?
    let league: League
    
    var fullName: String {
        "\(city) \(name)"
    }
}

extension Team {
    static let mockNBATeams: [Team] = [
        Team(name: "Lakers", abbreviation: "LAL", city: "Los Angeles", primaryColor: Color(red: 85/255, green: 37/255, blue: 130/255), secondaryColor: Color(red: 253/255, green: 185/255, blue: 39/255), logoName: "lakers", league: League.featured[0]),
        Team(name: "Warriors", abbreviation: "GSW", city: "Golden State", primaryColor: Color(red: 29/255, green: 66/255, blue: 138/255), secondaryColor: Color(red: 255/255, green: 199/255, blue: 44/255), logoName: "warriors", league: League.featured[0]),
        Team(name: "Celtics", abbreviation: "BOS", city: "Boston", primaryColor: Color(red: 0/255, green: 122/255, blue: 51/255), secondaryColor: .white, logoName: "celtics", league: League.featured[0]),
        Team(name: "Thunder", abbreviation: "OKC", city: "Oklahoma City", primaryColor: Color(red: 0/255, green: 125/255, blue: 195/255), secondaryColor: Color(red: 239/255, green: 59/255, blue: 36/255), logoName: "thunder", league: League.featured[0]),
        Team(name: "Pacers", abbreviation: "IND", city: "Indiana", primaryColor: Color(red: 0/255, green: 45/255, blue: 98/255), secondaryColor: Color(red: 253/255, green: 187/255, blue: 48/255), logoName: "pacers", league: League.featured[0])
    ]
    
    static let mockWNBATeams: [Team] = [
        Team(name: "Lynx", abbreviation: "MIN", city: "Minnesota", primaryColor: Color(red: 0/255, green: 47/255, blue: 108/255), secondaryColor: Color(red: 149/255, green: 203/255, blue: 252/255), logoName: "lynx", league: League.featured[1]),
        Team(name: "Storm", abbreviation: "SEA", city: "Seattle", primaryColor: Color(red: 0/255, green: 79/255, blue: 48/255), secondaryColor: Color(red: 255/255, green: 185/255, blue: 28/255), logoName: "storm", league: League.featured[1]),
        Team(name: "Sparks", abbreviation: "LA", city: "Los Angeles", primaryColor: Color(red: 85/255, green: 37/255, blue: 130/255), secondaryColor: Color(red: 253/255, green: 185/255, blue: 39/255), logoName: "sparks", league: League.featured[1]),
        Team(name: "Aces", abbreviation: "LV", city: "Las Vegas", primaryColor: .black, secondaryColor: .red, logoName: "aces", league: League.featured[1]),
        Team(name: "Wings", abbreviation: "DAL", city: "Dallas", primaryColor: Color(red: 0/255, green: 83/255, blue: 188/255), secondaryColor: Color(red: 200/255, green: 16/255, blue: 46/255), logoName: "wings", league: League.featured[1]),
        Team(name: "Mercury", abbreviation: "PHX", city: "Phoenix", primaryColor: Color(red: 85/255, green: 37/255, blue: 130/255), secondaryColor: Color(red: 255/255, green: 103/255, blue: 27/255), logoName: "mercury", league: League.featured[1])
    ]
    
    static let mockMLBTeams: [Team] = [
        Team(name: "Marlins", abbreviation: "MIA", city: "Miami", primaryColor: Color(red: 0/255, green: 163/255, blue: 224/255), secondaryColor: .black, logoName: "marlins", league: League.featured[2]),
        Team(name: "Pirates", abbreviation: "PIT", city: "Pittsburgh", primaryColor: .black, secondaryColor: Color(red: 253/255, green: 184/255, blue: 39/255), logoName: "pirates", league: League.featured[2]),
        Team(name: "Cubs", abbreviation: "CHC", city: "Chicago", primaryColor: Color(red: 14/255, green: 51/255, blue: 134/255), secondaryColor: Color(red: 204/255, green: 52/255, blue: 51/255), logoName: "cubs", league: League.featured[2]),
        Team(name: "Phillies", abbreviation: "PHI", city: "Philadelphia", primaryColor: Color(red: 232/255, green: 24/255, blue: 40/255), secondaryColor: Color(red: 0/255, green: 45/255, blue: 114/255), logoName: "phillies", league: League.featured[2]),
        Team(name: "Reds", abbreviation: "CIN", city: "Cincinnati", primaryColor: Color(red: 198/255, green: 1/255, blue: 31/255), secondaryColor: .black, logoName: "reds", league: League.featured[2]),
        Team(name: "Guardians", abbreviation: "CLE", city: "Cleveland", primaryColor: Color(red: 0/255, green: 56/255, blue: 93/255), secondaryColor: Color(red: 227/255, green: 25/255, blue: 55/255), logoName: "guardians", league: League.featured[2]),
        Team(name: "Braves", abbreviation: "ATL", city: "Atlanta", primaryColor: Color(red: 19/255, green: 39/255, blue: 79/255), secondaryColor: Color(red: 206/255, green: 17/255, blue: 65/255), logoName: "braves", league: League.featured[2]),
        Team(name: "Brewers", abbreviation: "MIL", city: "Milwaukee", primaryColor: Color(red: 12/255, green: 44/255, blue: 86/255), secondaryColor: Color(red: 255/255, green: 197/255, blue: 47/255), logoName: "brewers", league: League.featured[2]),
        Team(name: "Blue Jays", abbreviation: "TOR", city: "Toronto", primaryColor: Color(red: 19/255, green: 74/255, blue: 142/255), secondaryColor: Color(red: 232/255, green: 41/255, blue: 28/255), logoName: "bluejays", league: League.featured[2]),
        Team(name: "Cardinals", abbreviation: "STL", city: "St. Louis", primaryColor: Color(red: 196/255, green: 30/255, blue: 58/255), secondaryColor: .white, logoName: "cardinals", league: League.featured[2])
    ]
}