# ESPN Liquid Glass Prototype

## iOS 26 Developer Beta
**This app targets iOS 26.0 (Build 23A5260n)** - Released June 2025 as part of Apple's developer beta program. The app utilizes new iOS 26 APIs including:
- Native `Glass` effects with GPU acceleration
- `GlassEffectContainer` for morphing glass shapes
- Built-in `GlassButtonStyle` for consistent glass UI
- ProMotion-optimized rendering for 120Hz displays

## Project Overview
ESPN-style sports app prototype featuring:
- **Real ESPN API Integration**: Live scores, news, and video content
- **iOS 26 Glass Design**: Liquid glass effects using native iOS 26 APIs
- **Performance Optimized**: Off-main-thread image loading, structured concurrency
- **Clean Architecture**: Modular components with clear separation of concerns

## Current Architecture

### Core Features
✅ **ESPN API Integration**: Real data from ESPN's scoreboard, news, and watch APIs  
✅ **iOS 26 Glass Effects**: Native glass APIs with fallbacks for older iOS versions  
✅ **Smart Image Selection**: Automatically chooses best aspect ratio from ESPN's multiple formats  
✅ **Performance Optimized**: CachedNonBlockingImage, parallel data loading, NSCache  
✅ **Video Playback**: ESPN Watch integration with proper authentication handling  
✅ **Dark Mode Support**: Fully adaptive UI for light and dark modes  

### File Structure
```
ESPNLiquidGlass/
├── Core/
│   ├── API/
│   │   ├── ESPNAPIService.swift        # ESPN API integration with TLS handling
│   │   ├── ESPNAPIModels.swift         # Comprehensive data models
│   │   └── ESPNWatchAPIParser.swift    # Watch API specific parsing
│   └── Models/
│       ├── Article.swift               # Smart 16:9 image selection
│       ├── VideoItem.swift             # Video models with auth handling
│       └── Sport.swift                 # Sport categorization
├── Views/
│   ├── HomeView.swift                  # News feed with article cards
│   ├── ScoresView.swift                # Live scores with date navigation
│   ├── WatchView.swift                 # Video content browser
│   ├── iOS26GlassDemo.swift           # Glass effects showcase
│   └── Components/
│       ├── VideoCards.swift            # All video card variants
│       ├── VideoCategorySection.swift  # Category layout logic
│       ├── CachedNonBlockingImage.swift # Performance image loader
│       └── ArticleCard.swift           # News article display
└── Utils/
    └── ESPNGlassEffects_Unified.swift  # iOS 26 glass effects with fallbacks
```

## iOS 26 Glass Implementation

### Glass Effect Types
```swift
// Regular glass
.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))

// Prominent glass with more blur
.glassEffect(.prominent, in: Capsule())

// Interactive glass that responds to touch
.glassEffect(.regular.interactive(isPressed))

// Glass button style
Button("Watch Live") { }
    .buttonStyle(GlassButtonStyle())
```

### Glass Container for Morphing
```swift
GlassEffectContainer {
    // Content that can smoothly morph between shapes
}
.glassContainerShape(isExpanded ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: 20)))
```

## ESPN API Integration

### Watch API
- **Endpoint**: `https://watch.product.api.espn.com/api/product/v3/watchespn/web/home`
- **Authentication**: Videos with `authType: ["MVPD", "Direct", "Flagship"]` redirect to ESPN app
- **TLS Handling**: Custom URLSessionDelegate bypasses certificate validation for ESPN APIs

### Image Selection Algorithm
ESPN provides multiple aspect ratios (16:9, 5:2, 1:1). Our smart selection:
1. Calculate aspect ratio, prefer closest to 1.777 (16:9)
2. Check URL patterns for `_16-9` suffix
3. Fall back to largest resolution
4. Final fallback to first available

## Performance Optimizations

### CachedNonBlockingImage
- Loads images off main thread
- NSCache for memory management
- Supports contentMode parameter for proper aspect ratios
- Smooth fade-in transitions

### Structured Concurrency
```swift
// Parallel API calls
async let news = apiService.fetchNews()
async let scores = apiService.fetchScores()
let (newsData, scoresData) = await (news, scores)
```

## Recent Updates (June 2025)

### WatchView Architecture Cleanup (June 18)
- Separated inline components into dedicated files
- Fixed aspect ratio issues (`.fit` → `.fill`)
- Removed duplicate component definitions
- Maintained performance with CachedNonBlockingImage

### Video Playback Implementation (June 17)
- Added ESPN app deep linking for authenticated content
- Implemented playback URL resolution
- Added proper error handling with debug info

### Date Navigation Enhancement (June 16)
- Week-by-week pagination with TabView
- Fixed ESPN date parsing (`yyyy-MM-dd'T'HH:mm'Z'`)
- Added glass gradient overlays on navigation

## Known Issues & Future Work

### Current Limitations
- TabView date compression during swipe animations
- Arrow button animations override custom transitions

### Planned Improvements
- Custom page view for better animation control
- Enhanced error recovery for API failures
- Offline caching for better performance
- Widget extension for live scores

## Development Setup

### Requirements
- Xcode 16.0+ (for iOS 26 SDK)
- iOS 26.0 beta device or simulator
- ESPN API access (built into app)

### Build & Run
```bash
open ESPNLiquidGlass.xcodeproj
# Select iPhone 16 Pro simulator with iOS 26.0
# Build and run (⌘R)
```

### Testing Focus Areas
- Glass effects on ProMotion displays
- Video playback with/without ESPN app
- Image aspect ratio handling
- Dark/light mode transitions
- Performance during rapid scrolling

## Key Technical Decisions

### Why CachedNonBlockingImage over AsyncImage?
- AsyncImage blocks main thread during decode
- Our solution decodes on background queue
- NSCache provides automatic memory management
- Supports all required contentMode options

### Why Custom TLS Handling?
- ESPN APIs use certificates that fail standard validation
- Custom delegate allows app to function in development
- Production apps should use proper certificate validation

### Why iOS 26 Target?
- Native glass effects are GPU-accelerated
- No need for complex custom blur implementations
- Better performance on ProMotion displays
- Future-proof architecture

## Component Guidelines

### Creating New Components
1. Place in `Views/Components/` for reusability
2. Use semantic property names
3. Include comprehensive previews
4. Separate presentation from business logic
5. Use callbacks for user interactions

### Example Structure
```swift
struct ComponentName: View {
    // MARK: - Properties
    let data: DataType
    let onAction: () -> Void
    
    // MARK: - Body
    var body: some View {
        // Implementation
    }
    
    // MARK: - Previews
    #Preview {
        ComponentName(data: .mock, onAction: {})
    }
}
```