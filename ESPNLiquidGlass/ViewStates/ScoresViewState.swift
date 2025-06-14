import Foundation

enum ScoresViewState {
    case loading
    case loaded([SportGameData])
    case error(String)
    case empty
    
    // MARK: - Computed Properties
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var sportsData: [SportGameData]? {
        if case .loaded(let data) = self { return data }
        return nil
    }
    
    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
    
    var isEmpty: Bool {
        if case .empty = self { return true }
        return false
    }
    
    // MARK: - Helper Methods
    func filteredData(for selectedSports: Set<String>) -> [SportGameData] {
        guard let data = sportsData else { return [] }
        
        if selectedSports.contains("Top Events") {
            return data
        } else {
            return data.filter { sportData in
                selectedSports.contains(sportData.leagueAbbreviation)
            }
        }
    }
}