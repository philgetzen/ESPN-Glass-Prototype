import Foundation

enum HomeViewState {
    case loading
    case loaded([Article])
    case error(String)
    case empty
    
    // MARK: - Computed Properties
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var articles: [Article]? {
        if case .loaded(let articles) = self { return articles }
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
}