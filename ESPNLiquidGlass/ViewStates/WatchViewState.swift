import Foundation

enum WatchViewState {
    case loading
    case loaded([VideoCategory])
    case error(String)
    case empty
}