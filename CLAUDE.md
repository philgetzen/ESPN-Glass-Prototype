# ESPN Liquid Glass Prototype

> **🚀 Need to build immediately?** → [iOS26_QUICK_REFERENCE.md](iOS26_QUICK_REFERENCE.md)  
> **📖 Want the complete overview?** → Continue reading this document  
> **🔍 Need proof iOS 26 exists?** → [iOS26_BUILD_SUCCESS_GUIDE.md](iOS26_BUILD_SUCCESS_GUIDE.md)

## 📋 Documentation Guide

This project has comprehensive documentation organized for different purposes:

### 🚀 Quick Start & Development
- **`iOS26_QUICK_REFERENCE.md`** - Essential build commands, native APIs, and daily development reference
- **`CLAUDE_CODE_INSTRUCTIONS.md`** - Development guidelines, coding standards, and iOS 26 API usage patterns

### 📖 Complete Project Documentation  
- **`CLAUDE.md`** (this file) - Complete project overview, architecture, and feature documentation
- **`iOS26_BUILD_SUCCESS_GUIDE.md`** - Definitive proof iOS 26 exists with full build process documentation

### 🔧 Troubleshooting & History
- **`BUILD_SUCCESS_LOG.md`** - Build history and success records
- **`docs/scripts/`** - Build scripts and automation tools

### 📱 iOS 26 Resources
- **`ios26-docs/`** - Apple's iOS 26 API documentation and examples

### 🔧 Latest Swift & SwiftUI Documentation
- **`Development/docs/swift-language-documentation.md`** - Latest Swift language documentation with iOS 26 APIs
- **`Development/docs/swiftui-framework-documentation.md`** - Latest SwiftUI framework documentation and patterns

**Start with `iOS26_QUICK_REFERENCE.md` for immediate development needs, then refer to this file for comprehensive project understanding.**

---

## IMPORTANT: iOS Version and Glass Effects

### Current Status: ✅ BUILD SUCCESSFUL!
**This app uses iOS 26.0+ Beta Liquid Glass APIs** - The new Liquid Glass design system is part of iOS 26 Developer Beta, providing advanced glass effects with morphing capabilities.

**🎉 CONFIRMED: iOS 26 EXISTS AND BUILDS SUCCESSFULLY!**  
- ✅ Built with Xcode-beta and iOS 26.0 SDK (iPhoneSimulator26.0.sdk)
- ✅ All native Glass APIs working: `.glassEffect(.regular)`, `GlassButtonStyle()`
- ✅ iPhone 16 Pro simulator running iOS 26.0
- ✅ See `iOS26_BUILD_SUCCESS_GUIDE.md` for complete documentation

### iOS 26 Beta Native APIs:
- `.glassEffect(_:in:isEnabled:)` - Applies Liquid Glass effect to views
- `Glass` type with three variants:
  - `.regular` - Standard glass effect
  - `.prominent` - More prominent glass effect
  - `.thick` - Thicker glass effect
- `.interactive(_:)` modifier - Makes glass respond to interaction
- `GlassEffectContainer` - Native container for morphing glass shapes
- `GlassButtonStyle` - Native button style with glass border artwork
- `glassEffectID(_:in:)` - Associates identity for animations
- `glassEffectTransition(_:)` - Describes transition animations
- `glassEffectUnion(id:namespace:)` - Combines multiple glass effects

### What We Enhanced:
- `ESPNGlassDensity` - Maps to native Glass types (.light → .regular, .medium → .prominent, .heavy → .thick)
- `espnGlassEffect()` - Wrapper with fallback support for pre-iOS 26
- `espnGlassCard()` - Adds shadows and styling to native glass
- `ESPNGlassContainer` - Enhanced wrapper around native `GlassEffectContainer`
- Performance optimizations with `drawingGroup()` and `compositingGroup()`

## Project Overview
ESPN-style sports app prototype featuring:
- **Real ESPN API Integration**: Live scores, news, and video content
- **iOS 18+ Glass Design**: Native glass effects with custom ESPN styling
- **Performance Optimized**: Off-main-thread image loading, structured concurrency
- **Clean Architecture**: Modular components with clear separation of concerns

## Glass Implementation - iOS 26 Beta

### Native iOS 26 Glass Effects
```swift
// Basic glass effect with different densities
.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
.glassEffect(.prominent, in: RoundedRectangle(cornerRadius: 16))
.glassEffect(.thick, in: RoundedRectangle(cornerRadius: 16))

// Interactive glass
.glassEffect(.regular.interactive(isPressed), in: Capsule())

// Native glass button style
Button("Action") { }
    .buttonStyle(GlassButtonStyle())

// Glass effect container for morphing
GlassEffectContainer {
    VStack {
        // Views that can morph between glass shapes
    }
}

// Glass transitions and animations
.glassEffectID("myView", in: namespace)
.glassEffectTransition(.scale)
.glassEffectUnion(id: "group", namespace: namespace)
```

### ESPN Enhanced Glass System
```swift
// ESPN glass effect with automatic iOS 26 mapping
Text("Live Score")
    .espnGlassEffect(density: .medium) // Uses .prominent under the hood

// ESPN glass card with shadows
VStack { ... }
    .espnGlassCard(cornerRadius: 16, density: .heavy) // Uses .thick glass

// ESPN glass button (uses native GlassButtonStyle on iOS 26+)
Button("Watch Now") { }
    .espnGlassButtonStyle()

// ESPN container (enhanced GlassEffectContainer)
if #available(iOS 26.0, *) {
    ESPNGlassContainer(density: .light) {
        Text("Content")
    }
}

// Interactive glass with ESPN wrapper
Text("Press Me")
    .espnGlassEffect(density: .medium, isInteractive: true)
```

## Current Architecture

### Core Features
✅ **ESPN API Integration**: Real data from ESPN's scoreboard, news, and watch APIs  
✅ **iOS 26+ Liquid Glass Effects**: Native Glass APIs with `.regular`, `.prominent`, `.thick` variants  
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
│   └── Components/
│       ├── VideoCards.swift            # All video card variants
│       ├── VideoCategorySection.swift  # Category layout logic
│       ├── CachedNonBlockingImage.swift # Performance image loader
│       └── ArticleCard.swift           # News article display
└── Utils/
    └── ESPNGlassEffects_Unified.swift  # Custom ESPN glass system (NOT native iOS)
```

## ESPN Glass Effects Implementation

### Our Glass System (ESPNGlassEffects_Unified.swift)
```swift
// Density levels (OUR SYSTEM)
public enum ESPNGlassDensity {
    case light   // Uses .ultraThinMaterial
    case medium  // Uses .thinMaterial
    case heavy   // Uses .regularMaterial
}

// Custom button style
public struct ESPNGlassButtonStyle: ButtonStyle {
    // Uses native .glassEffect(.regular) on iOS 18+
    // Falls back to .ultraThinMaterial on iOS 17
}

// Custom container (iOS 18+ only)
@available(iOS 18.0, *)
public struct ESPNGlassContainer<Content: View>: View {
    // Combines materials with .glassEffect(.regular)
}
```

### Correct Usage Examples
```swift
// ✅ CORRECT - Native iOS 26 glass effects
Text("iOS 26 Glass")
    .padding()
    .glassEffect(.prominent, in: RoundedRectangle(cornerRadius: 16))

// ✅ CORRECT - Interactive glass
Button("Tap Me") { }
    .glassEffect(.regular.interactive(true), in: Capsule())

// ✅ CORRECT - Native glass button style
Button("Action") { }
    .buttonStyle(GlassButtonStyle())

// ✅ CORRECT - Glass effect container
GlassEffectContainer {
    VStack {
        Text("Morphable Content")
    }
}

// ✅ CORRECT - ESPN enhanced wrappers
ArticleCard(article: article)
    .espnGlassCard(density: .medium) // Maps to .prominent

Button("Watch Live") { }
    .espnGlassButtonStyle() // Uses native GlassButtonStyle

// ✅ CORRECT - Glass transitions
@Namespace private var namespace
Text("Animated")
    .glassEffectID("text", in: namespace)
    .glassEffectTransition(.scale)
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
- Supports contentMode parameter (.fill or .fit)
- Smooth fade-in transitions

### Structured Concurrency
```swift
// Parallel API calls
async let news = apiService.fetchNews()
async let scores = apiService.fetchScores()
let (newsData, scoresData) = await (news, scores)
```

## Recent Updates

### WatchView Architecture Cleanup (June 18, 2025)
- Separated inline components into dedicated files
- Fixed aspect ratio issues (`.fit` → `.fill`)
- Removed duplicate component definitions
- Maintained performance with CachedNonBlockingImage

### Video Playback Implementation (June 17, 2025)
- Added ESPN app deep linking for authenticated content
- Implemented playback URL resolution
- Added proper error handling with debug info

### iOS 26 Glass Effects Implementation (June 2025)
- Implemented native iOS 26 Liquid Glass APIs
- Added support for `.regular`, `.prominent`, and `.thick` glass types
- Integrated `GlassEffectContainer` for morphing effects
- Added interactive glass support with `.interactive()` modifier
- Implemented glass transitions and animations

## Development Setup

### Requirements
- Xcode 17.0+ (for iOS 26 SDK Beta)
- iOS 26.0+ device or simulator (for Liquid Glass effects)
- iOS 18.0+ for fallback support
- ESPN API access (built into app)

### Build & Run
```bash
open ESPNLiquidGlass.xcodeproj
# Select iPhone 15 Pro or newer simulator
# Build and run (⌘R)
```

### Testing Focus Areas
- Liquid Glass effects on iOS 26+ devices
- Glass morphing animations with `GlassEffectContainer`
- Interactive glass with `.interactive()` modifier
- Glass transitions and animations
- Fallback materials on iOS 18-25
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

### Why Custom Glass System?
- iOS 18 only provides `.regular` glass type
- We wanted density variations (.light, .medium, .heavy)
- Consistent API across iOS versions
- Better control over visual appearance

### Why iOS 26.0 Target?
- Liquid Glass effects were introduced in iOS 26.0 Beta
- Provides advanced glass morphing capabilities
- Native support for interactive glass effects
- Built-in glass transitions and animations
- Fallbacks for iOS 18-25 ensure wider compatibility

### About the iOS 26 Documentation
This project uses official iOS 26 Beta documentation from Apple Developer portal:
- `glassEffect(_:in:isEnabled:)` - Core modifier
- `GlassEffectContainer` - For morphing effects
- `GlassButtonStyle` - Native button styling
- Interactive and transition modifiers

### Latest Documentation Resources
**ALWAYS refer to the latest documentation when developing:**
- **`Development/docs/swift-language-documentation.md`** - Contains the most current Swift language features, including iOS 26 APIs, concurrency patterns, actor model, generics, and error handling
- **`Development/docs/swiftui-framework-documentation.md`** - Up-to-date SwiftUI patterns, state management (@State, @Binding, @EnvironmentObject), view composition, lifecycle management, and best practices

These documents were fetched from the latest Swift and SwiftUI repositories via Context7 MCP server and contain cutting-edge features and APIs.

**Development Note**: 
- Primary target: iOS 26.0+ for full Liquid Glass features
- Fallback support: iOS 18.0+ with limited glass effects
- Legacy support: Pre-iOS 18 with material effects
- **Use latest documentation**: Always reference `Development/docs/` for current Swift/SwiftUI patterns

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
        content
            .espnGlassCard() // Use our ESPN glass system
    }
    
    // MARK: - Previews
    #Preview {
        ComponentName(data: .mock, onAction: {})
    }
}
```

## Troubleshooting

### Glass Effects Not Showing
- Check iOS version: Must be iOS 26.0+ for full features
- iOS 18-25 will show limited glass effects
- Verify proper availability checks
- Ensure using correct Glass variants (.regular, .prominent, .thick)

### Performance Issues
- Use CachedNonBlockingImage, not AsyncImage
- Implement lazy loading in scroll views
- Check for main thread blocking

### API Errors
- ESPN APIs use custom TLS handling
- Check network connectivity
- Verify API endpoints haven't changed