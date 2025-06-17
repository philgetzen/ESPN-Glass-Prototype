# ESPN Liquid Glass Prototype - Development Session

## Project Overview
This is an ESPN-style sports app prototype with a liquid glass design aesthetic. The app features real ESPN API integration and custom SwiftUI components with glass-like visual effects.

## Recent Development Session Summary

### Major Work Completed

#### 1. ScoresView Date Selector Enhancement
- **Fixed date parsing issues**: ESPN API returns dates in format `2025-06-14T00:30Z` which wasn't being parsed correctly
- **Implemented smart image selection**: Added algorithm to prefer 16:9 aspect ratio images from ESPN API to fix article card layout issues
- **Added paginated date navigation**: Replaced continuous scroll with week-by-week pagination using TabView
- **Enhanced with glass effects**: Added gradient overlays on arrow zones for frosted glass appearance

#### 2. HomeView Article Card Fixes
- **Root cause identified**: ESPN API returns multiple image aspect ratios (5:2, 16:9, etc.)
- **Smart image selection implemented**: Algorithm prioritizes 16:9 images, then falls back to URL pattern matching (`_16-9`), then largest available
- **Fixed layout consistency**: All article cards now maintain proper sizing regardless of source image aspect ratio

#### 3. Start Times Display
- **Fixed time formatting**: ESPN API dates weren't being parsed correctly due to format mismatch
- **Added proper timezone conversion**: Times now display in local timezone
- **Implemented game state detection**: Shows appropriate content based on live/upcoming/final status
- **Network information display**: Shows broadcast network when available

### Current State

#### Working Features
✅ **ESPN API Integration**: Real data from ESPN's scoreboard and news APIs  
✅ **ESPN Watch API**: Video content loading from proper Watch API endpoint  
✅ **Smart Image Selection**: Automatically chooses best aspect ratio images  
✅ **Date Pagination**: Week-by-week navigation with smooth animations  
✅ **Start Times**: Proper parsing and display of game times  
✅ **Glass Effects**: Gradient overlays on date selector arrows  
✅ **Responsive Design**: Works in both light and dark modes  

#### Known Issues
❌ **Date smooshing during transitions**: Dates compress at edges during TabView swipe animations (attempted multiple fixes, needs different approach)
❌ **Arrow sliding animation**: TabView overrides custom animations for arrow button taps

### Key Technical Implementations

#### Smart Image Selection Algorithm (Article.swift:139-172)
```swift
private static func selectBest16x9Image(from images: [NewsArticle.ArticleImage]?) -> String? {
    // 1. Try aspect ratio calculation (width/height ≈ 1.777)
    // 2. Try URL pattern matching (_16-9)
    // 3. Fall back to largest available image
    // 4. Final fallback to first image
}
```

#### Date Parsing Fix (ScoresView.swift:530-547)
```swift
private func formatGameTime() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    // Convert to local time for display
}
```

#### Paginated Date Selector (ScoresView.swift:142-152)
```swift
TabView(selection: $currentWeekOffset) {
    ForEach(-10...10, id: \.self) { weekOffset in
        weekView(for: weekOffset).tag(weekOffset)
    }
}
.tabViewStyle(.page(indexDisplayMode: .never))
```

### Development Notes

#### ESPN API Insights
- **Multiple image formats**: API provides both 5:2 and 16:9 versions of same image
- **Time format**: Uses `yyyy-MM-dd'T'HH:mm'Z'` (UTC without fractional seconds)
- **Game states**: Uses `pre`, `in`, `post` for upcoming/live/final status
- **Network data**: Available in `competitions.broadcasts.names` array

#### UI/UX Learnings
- **TabView limitations**: Built-in page animation overrides custom withAnimation calls
- **GeometryReader issues**: Causes layout compression in certain contexts
- **Glass effects**: Need adaptive approaches for light/dark mode compatibility
- **Date spacing**: Natural HStack spacing works better than fixed calculations

### Commands for Testing
```bash
# Build and run
open ESPNLiquidGlass.xcodeproj
# Test date navigation, start times, article cards, image aspect ratios
```

### Future Improvements Needed
1. **Fix date smooshing**: Try custom view transitions instead of TabView
2. **Improve arrow animations**: Consider custom sliding implementation
3. **Performance optimization**: Add image caching for better performance
4. **Error handling**: Add better fallbacks for API failures

### File Structure
- `ScoresView.swift`: Main scores interface with date selector and game listings
- `HomeView.swift`: Article feed with smart image selection
- `Article.swift`: Model with intelligent image selection algorithm
- `ESPNAPIService.swift`: API integration with real ESPN data
- `ESPNAPIModels.swift`: Comprehensive data models for ESPN responses
- `LiquidGlassEffects.swift`: Custom glass-like visual effects

This session focused heavily on data parsing, image handling, and UI polish. The core functionality is solid with real ESPN integration working well.

## Watch API Restoration (June 16, 2025)

### Issue Resolution
- **Problem**: Watch tab was using News API workaround instead of proper ESPN Watch API, leading to TLS errors
- **Root Cause**: `fetchVideoContent()` method was replaced with News API fallback during previous session
- **Solution**: Restored proper Watch API implementation using existing TLS infrastructure

### Technical Details
- **Watch API Endpoint**: `https://watch.product.api.espn.com/api/product/v3/watchespn/web/home?lang=en&features=continueWatching,flagship,pbov7,high-volume-row,watch-web-redesign,imageRatio58x13,promoTiles,openAuthz,video-header,explore-row,button-service,inline-header&headerBgImageWidth=1280&countryCode=US&tz=UTC-0400`
- **TLS Solution Already In Place**: 
  - Custom `ESPNURLSessionDelegate` bypasses SSL certificate validation (ESPNAPIService.swift:4-16)
  - ATS exceptions configured in Info.plist (lines 51-59)
  - URLSession properly configured with custom delegate (line 36)
- **Parser Integration**: Using existing `ESPNWatchAPIParser` to convert API response to `VideoCategory` models

### Files Modified
- `ESPNAPIService.swift:218-280`: Replaced News API workaround with proper Watch API call
- `ESPNAPIService.swift:47`: Added missing `APIError.invalidResponse` case
- `CLAUDE.md`: Updated to reflect Watch API restoration

### Current Status
✅ **Watch tab fully functional** with real ESPN video content
✅ **TLS/SSL issues resolved** using existing infrastructure
✅ **Video categories displaying** properly from Watch API buckets

## ESPN Watch Video Playback Implementation (June 17, 2025)

### Implementation Overview
Implemented proper video URL handling for ESPN Watch content based on authentication requirements (authType). Videos requiring authentication through ESPN providers redirect to the ESPN app, while unrestricted content attempts direct playback.

### Technical Implementation

#### 1. API Model Updates
- **ESPNWatchContent**: Added `authType: [String]?` field and full `streams: [ESPNWatchStream]?` structure
- **ESPNWatchStream**: New model capturing stream authentication and links:
  ```swift
  struct ESPNWatchStream {
      let authType: [String]?
      let links: ESPNWatchStreamLinks?
      let source: String?
      let network: String?
  }
  ```
- **ESPNWatchStreamLinks**: Contains playback URLs including `appPlay`, `web`, and `mobile`

#### 2. VideoItem Model Enhancements
- Added `authType: [String]?` - authentication types required for video
- Added `streamingURL: String?` - direct streaming URL from appPlay link
- Added `contentId: String?` - ESPN content ID for deep linking
- Added computed property `requiresESPNApp` that checks for restricted authTypes: `["MVPD", "Direct", "Flagship", "ISP"]`

#### 3. Playback Logic (WatchView.swift:173-218)
- **Empty authType []**: Attempts playback with streamingURL if available
- **Restricted authType**: Shows one-time alert, then redirects to ESPN app using deep link
- **No URL available**: Shows error alert with debug information
- **ESPN App Deep Link Format**: `sportscenter://x-callback-url/showVideo?videoID={contentId}`
- **Fallback**: Opens App Store if ESPN app not installed

#### 4. Configuration Updates
- Added `LSApplicationQueriesSchemes` to Info.plist with `sportscenter` scheme
- Enables app to check if ESPN app is installed before attempting deep link

### User Experience Flow
1. **First restricted content tap**: Shows alert explaining ESPN app requirement
2. **Subsequent taps**: Directly opens ESPN app without alert
3. **Playable content**: Opens in-app video player
4. **Missing data**: Shows error with debug info (contentId, authType)

### Key Files Modified
- `ESPNWatchAPIParser.swift`: Stream parsing logic (lines 279-311, 477-526)
- `ESPNAPIModels.swift`: VideoItem model updates (lines 430-438)
- `WatchView.swift`: Video tap handling and deep linking (lines 173-218)
- `Info.plist`: ESPN app URL scheme registration (lines 60-63)

### Debug Output
Parser logs authentication and streaming info for each video:
```
🎬 Video: {title}
   - Content ID: {id}
   - AuthType: {authType array}
   - Streaming URL: {appPlay URL or "none"}
```

## ESPN Logo Sizing Issue Fix (June 16, 2025)

### Problem Description
ESPN logo in WatchView toolbar was oscillating between two sizes (97×24px and 36×24px) during view state changes when videos loaded, while other tabs maintained consistent sizing.

### Root Cause Analysis
- **Initial render**: Logo correctly sized to ~97px wide × 24px high
- **State transitions**: During `loadVideoContent()` execution and `viewState` changes from `.loading` → `.loaded`, SwiftUI was re-rendering the toolbar
- **Layout constraint conflict**: Original code used `.frame(height: 24)` with dynamic width calculation based on aspect ratio
- **Animation cycles**: During re-renders, SwiftUI temporarily applied different width constraints causing oscillation

### Debugging Process
1. **Added debug logging**: Tracked logo size changes with GeometryReader and console output
2. **Identified timing**: Size changes correlated exactly with video content loading completion
3. **Isolated issue**: Problem was specific to WatchView due to its unique state management and view hierarchy
4. **Confirmed pattern**: Logo oscillated between `(97.05, 24.0)` and `(36.0, 24.0)` consistently

### Solution Implementation
- **Fixed both dimensions**: Changed from `.frame(height: 24)` to `.frame(width: 36, height: 24)` in ESPNToolbar.swift
- **Prevented oscillation**: Explicit width constraint prevents SwiftUI from recalculating width during view updates
- **Consistent sizing**: All tabs now display logo at uniform 36×24 pixels

### Files Modified
- `ESPNToolbar.swift:42`: Changed standard logo frame from height-only to explicit width×height dimensions

### Key Learnings
- **SwiftUI re-rendering**: View state changes can cause toolbar elements to recalculate layout constraints
- **Dimension specificity**: For stable UI elements, specify both width and height rather than relying on aspect ratio calculations
- **Debug methodology**: GeometryReader with onChange callbacks provides precise insight into layout changes

### Current Status
✅ **ESPN logo displays consistently** across all tabs at 36×24 pixels
✅ **No size oscillation** during WatchView content loading
✅ **Toolbar styling maintained** with proper dark mode appearance

## Component Creation Guidelines

When creating new UI components, follow these patterns:

### 1. Location
- Place reusable components in `Views/Components/`
- Keep screen-specific components within their parent view file

### 2. Structure
```swift
import SwiftUI

struct ComponentName: View {
    // MARK: - Properties
    let requiredProperty: Type
    let onAction: () -> Void  // For callbacks
    
    // MARK: - Body
    var body: some View {
        // Implementation
    }
    
    // MARK: - Private Views
    private var subView: some View {
        // Break down complex views
    }
    
    // MARK: - Private Methods
    private func helperMethod() {
        // Any helper logic
    }
}

// MARK: - Previews
#Preview("Description") {
    ComponentName(
        requiredProperty: mockValue,
        onAction: {}
    )
    .background(Color(UIColor.systemBackground))
}
```

### 3. Best Practices
- Use semantic property names (e.g., `onArticleTap` not `onTap`)
- Include multiple preview variants showing different states
- Extract complex subviews into private computed properties
- Keep components focused on presentation, not business logic
- Pass callbacks for user interactions rather than handling state internally