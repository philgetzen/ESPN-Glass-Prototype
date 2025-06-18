import SwiftUI

// MARK: - Video Category Section Component
// This handles the layout logic for different category types in WatchView

struct VideoCategorySection: View {
    let category: VideoCategory
    let onVideoTap: (VideoItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Handle different category types based on parser tags
            if hasExploreTag {
                exploreTileView
            } else if hasInlineHeaderTag && category.videos.count == 1 {
                heroTileView
            } else {
                standardCategoryView
            }
        }
    }
    
    // MARK: - Layout Views
    
    private var exploreTileView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if shouldShowTitle {
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(category.videos) { video in
                        ExploreTileCard(video: video) {
                            onVideoTap(video)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var heroTileView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if hasInlineHeaderTag {
                if let video = category.videos.first {
                    InlineHeaderCard(category: category, video: video) {
                        onVideoTap(video)
                    }
                }
            } else {
                if shouldShowTitle {
                    HStack {
                        Text(category.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                if let video = category.videos.first {
                    Button(action: { onVideoTap(video) }) {
                        ZStack {
                            // Thumbnail with fixed aspect ratio
                            CachedNonBlockingImage(url: video.thumbnailURL, contentMode: .fill)
                                .aspectRatio(getAspectRatio(for: video), contentMode: .fit)
                                .clipped()
                            
                            // Live badge overlay
                            if video.isLive {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("LIVE")
                                            .font(.system(size: 10))
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.red)
                                            .cornerRadius(4)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                }
                                .padding(8)
                            }
                            
                            // Content overlay
                            VStack {
                                Spacer()
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(video.title)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .lineLimit(2)
                                        
                                        if let description = video.description {
                                            Text(description)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                                .lineLimit(2)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.black.opacity(0.9), Color.clear],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                            }
                        }
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var standardCategoryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if shouldShowTitle {
                HStack {
                    Text(category.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("See All")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 12) {
                    ForEach(sortedVideos()) { video in
                        videoCardForContent(video: video, onTap: { onVideoTap(video) })
                    }
                }
                .padding(.horizontal)
                .padding(.trailing, hasLargeCards ? 20 : 0)
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }
    
    // MARK: - Tag Detection
    
    private var hasExploreTag: Bool {
        category.tags.contains("explore_tile") || category.tags.contains("explore")
    }
    
    private var hasInlineHeaderTag: Bool {
        category.tags.contains("inline-header")
    }
    
    private var hasBreakoutRowTag: Bool {
        let isSpecialContentRow = isFeaturedRow || isAlsoLiveRow
        return category.tags.contains("BREAKOUT_ROW_LEAGUES") && 
               !isSpecialContentRow &&
               (isLeagueSportOrConference(category.name) || category.name.lowercased().contains("league"))
    }
    
    private var isFeaturedRow: Bool {
        category.name.lowercased().contains("featured")
    }
    
    private var isAlsoLiveRow: Bool {
        category.priority == 3
    }
    
    private var shouldShowTitle: Bool {
        if hasExploreTag {
            return false
        }
        return category.showTitle && !category.tags.contains("noTitle")
    }
    
    private var hasLargeCards: Bool {
        category.videos.contains { video in
            video.size?.lowercased() == "lg" || video.size?.lowercased() == "large"
        }
    }
    
    // MARK: - Helper Functions
    
    private func isLeagueSportOrConference(_ name: String) -> Bool {
        let lowerName = name.lowercased()
        return lowerName == "leagues" || lowerName == "sports" || lowerName == "conferences"
    }
    
    private func isNetwork(_ name: String) -> Bool {
        let lowerName = name.lowercased()
        return lowerName == "channels" || lowerName.contains("network")
    }
    
    private func getAspectRatio(for video: VideoItem) -> CGFloat {
        if video.type?.lowercased() == "inlineheader" {
            return 58.0 / 13.0
        }
        return 16.0 / 9.0
    }
    
    private func sortedVideos() -> [VideoItem] {
        return category.videos
    }
    
    private func shouldUseSquareForFirstItem(_ video: VideoItem) -> Bool {
        return hasBreakoutRowTag && video == sortedVideos().first
    }
    
    // MARK: - Video Card Selection
    
    @ViewBuilder
    private func videoCardForContent(video: VideoItem, onTap: @escaping () -> Void) -> some View {
        if video.tags.contains("rowCap") || shouldUseSquareForFirstItem(video) {
            SquareThumbnailCard(video: video, onTap: onTap)
        } else {
            let categoryName = category.name.lowercased()
            
            switch video.layoutType {
            case .poster where !categoryName.contains("shows"):
                PosterVideoCard(video: video, onTap: onTap)
            case .show, .poster:
                ShowVideoCard(video: video, onTap: onTap)
            case .circle where isLeagueSportOrConference(category.name):
                CircleThumbnailCard(video: video, onTap: onTap)
            case .square where isNetwork(category.name):
                SquareThumbnailCard(video: video, onTap: onTap)
            case .large:
                LargeVideoCard(video: video, onTap: onTap)
            case .small:
                SmallVideoCard(video: video, onTap: onTap)
            default:
                MediumVideoCard(video: video, onTap: onTap)
            }
        }
    }
}
