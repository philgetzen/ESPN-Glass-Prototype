import SwiftUI

// MARK: - Tap to Top functionality
// iOS automatically handles status bar tap to scroll to top for the primary scroll view
// in each view controller. This happens automatically for ScrollView and List in SwiftUI.
// 
// The key requirements are:
// 1. Only one scroll view should have scrollsToTop = true in the view hierarchy
// 2. The scroll view should be the primary scrollable content
// 3. The scroll view should be visible and not covered by other views
//
// SwiftUI automatically configures this for most cases, but if there are issues,
// we can help by ensuring proper configuration.