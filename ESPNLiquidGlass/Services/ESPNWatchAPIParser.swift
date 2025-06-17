import Foundation

/// ESPN Watch API response structure models
struct ESPNWatchAPIResponse {
    let page: ESPNWatchPage?
}

struct ESPNWatchPage {
    let buckets: [ESPNWatchBucket]?
    let name: String?
    let tracking: [String: Any]?
    let attributes: [String: Any]?
    let layout: String?
    let isTveOnly: Bool?
    let edition: String?
    let isDtcOnly: Bool?
    let sfbEnabled: Bool?
    
    init(buckets: [ESPNWatchBucket]? = nil,
         name: String? = nil,
         tracking: [String: Any]? = nil,
         attributes: [String: Any]? = nil,
         layout: String? = nil,
         isTveOnly: Bool? = nil,
         edition: String? = nil,
         isDtcOnly: Bool? = nil,
         sfbEnabled: Bool? = nil) {
        self.buckets = buckets
        self.name = name
        self.tracking = tracking
        self.attributes = attributes
        self.layout = layout
        self.isTveOnly = isTveOnly
        self.edition = edition
        self.isDtcOnly = isDtcOnly
        self.sfbEnabled = sfbEnabled
    }
}

struct ESPNWatchBucket {
    let name: String?
    let contents: [ESPNWatchContent]?
    let tags: [String]?
    
    init(name: String? = nil, contents: [ESPNWatchContent]? = nil, tags: [String]? = nil) {
        self.name = name
        self.contents = contents
        self.tags = tags
    }
}

struct ESPNWatchContent {
    // Basic identification
    let id: String?
    let type: String?
    let name: String?
    let title: String?
    let shortName: String?
    let headline: String?
    let subtitle: String?
    
    // Images
    let imageHref: String?
    let backgroundImageHref: String?
    let iconHref: String?
    let imageIcon: String?
    let imageFormat: String?
    let ratio: String?
    
    // Video metadata
    let duration: TimeInterval?
    let isLive: Bool?
    let isEvent: Bool?
    let isLocked: Bool?
    let isPremium: Bool?
    let isSharePlayContent: Bool?
    let shouldTrackProgress: Bool?
    
    // Content details
    let description: String?
    let caption: String?
    let size: String?
    let status: String?
    
    // Dates and timing
    let date: String?
    let time: String?
    let utc: String?
    let shortDate: String?
    let originalPublishDate: String?
    
    // Sports-specific
    let eventId: String?
    let eventType: String?
    let score: String?
    
    // Navigation
    let links: [ESPNWatchLink]?
    
    // Categorization
    let catalog: String?
    let karnakCategoryId: String?
    let karnakContentSourceId: String?
    
    // Flags
    let isTveOnly: Bool?
    let isDtcOnly: Bool?
    let isPersonalized: Bool?
    let includeSponsor: Bool?
    
    // Progress
    let progress: Double?
    
    // Additional metadata
    let showKey: String?
    let streams: [ESPNWatchStream]?
    let keywords: [String]?
    let pillMetadata: [String: Any]?
    let tracking: [String: Any]?
    let tags: [String]?
    let autoplay: Bool?
    let authType: [String]?
}

struct ESPNWatchLink {
    let url: String?
    let type: String?
    let rel: String?
}

struct ESPNWatchStream {
    let authType: [String]?
    let links: ESPNWatchStreamLinks?
    let source: String?
    let network: String?
}

struct ESPNWatchStreamLinks {
    let appPlay: String?
    let web: String?
    let mobile: String?
    let play: String?
}

// MARK: - Parser Class

final class ESPNWatchAPIParser {
    
    /// Parses ESPN Watch API response into structured data
    static func parseResponse(from data: Data) -> ESPNWatchAPIResponse? {
        return parseManually(from: data)
    }
    
    /// Manual parsing for dynamic content
    private static func parseManually(from data: Data) -> ESPNWatchAPIResponse? {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return nil
            }
            
            
            var buckets: [ESPNWatchBucket] = []
            
            // Look for buckets in page object
            if let page = json["page"] as? [String: Any],
               let bucketsArray = page["buckets"] as? [[String: Any]] {
                
                
                for (index, bucketData) in bucketsArray.enumerated() {
                    let bucketName = bucketData["name"] as? String ?? "Bucket \(index)"
                    let bucketTags = bucketData["tags"] as? [String]
                    
                    var contents: [ESPNWatchContent] = []
                    
                    if let contentsArray = bucketData["contents"] as? [[String: Any]] {
                        for contentData in contentsArray {
                            if let content = parseContent(from: contentData, bucketTags: bucketTags, bucketData: bucketData) {
                                contents.append(content)
                            }
                        }
                    }
                    
                    buckets.append(ESPNWatchBucket(name: bucketName, contents: contents, tags: bucketTags))
                }
            }
            
            let page = ESPNWatchPage(buckets: buckets)
            return ESPNWatchAPIResponse(page: page)
            
        } catch {
            return nil
        }
    }
    
    /// Parses individual content item
    private static func parseContent(from data: [String: Any], bucketTags: [String]? = nil, bucketData: [String: Any]? = nil) -> ESPNWatchContent? {
        // Extract all the fields we care about
        let id = data["id"] as? String
        let type = data["type"] as? String
        let name = data["name"] as? String
        let title = data["title"] as? String
        let shortName = data["shortName"] as? String
        let headline = data["headline"] as? String
        let subtitle = data["subtitle"] as? String
        
        // Images
        let imageHref = data["imageHref"] as? String
        
        // Handle nested backgroundImage object
        var backgroundImageHref: String?
        
        // For inline-header content, check bucket-level backgroundImage first
        if type?.lowercased() == "inlineheader", let bucketData = bucketData {
            if let bucketBackgroundImage = bucketData["backgroundImage"] as? [String: Any],
               let href = bucketBackgroundImage["href"] as? String {
                backgroundImageHref = href
                }
        }
        
        // Fallback to content-level backgroundImage
        if backgroundImageHref == nil {
            if let backgroundImageData = data["backgroundImage"] as? [String: Any],
               let href = backgroundImageData["href"] as? String {
                backgroundImageHref = href
            } else {
                backgroundImageHref = data["backgroundImageHref"] as? String
            }
        }
        
        let iconHref = data["iconHref"] as? String
        let imageIcon = data["imageIcon"] as? String  // Alternative image field
        let imageFormat = data["imageFormat"] as? String
        let ratio = data["ratio"] as? String
        
        // Video metadata
        let duration = data["duration"] as? TimeInterval
        let isLive = data["isLive"] as? Bool
        let isEvent = data["isEvent"] as? Bool
        let isLocked = data["isLocked"] as? Bool
        let isPremium = data["premium"] as? Bool
        let isSharePlayContent = data["isSharePlayContent"] as? Bool
        let shouldTrackProgress = data["shouldTrackProgress"] as? Bool
        
        // Content details
        let description = data["description"] as? String
        let caption = data["caption"] as? String
        let size = data["size"] as? String
        let status = data["status"] as? String
        
        // Dates
        let date = data["date"] as? String
        let time = data["time"] as? String
        let utc = data["utc"] as? String
        let shortDate = data["shortDate"] as? String
        let originalPublishDate = data["originalPublishDate"] as? String
        
        // Sports-specific
        let eventId = data["eventId"] as? String
        let eventType = data["eventType"] as? String
        let score = data["score"] as? String
        
        // Other flags
        let isTveOnly = data["isTveOnly"] as? Bool
        let isDtcOnly = data["isDtcOnly"] as? Bool
        let isPersonalized = data["isPersonalized"] as? Bool
        let includeSponsor = data["includeSponsor"] as? Bool
        
        let progress = data["progress"] as? Double
        let showKey = data["showKey"] as? String
        
        // Parse streams array with full structure
        var parsedStreams: [ESPNWatchStream]? = nil
        if let streamsArray = data["streams"] as? [[String: Any]] {
            parsedStreams = streamsArray.compactMap { streamData in
                let authType = streamData["authTypes"] as? [String]
                let source = streamData["source"] as? String
                let network = streamData["network"] as? String
                
                // Parse links object
                var streamLinks: ESPNWatchStreamLinks? = nil
                if let linksData = streamData["links"] as? [String: Any] {
                    streamLinks = ESPNWatchStreamLinks(
                        appPlay: linksData["appPlay"] as? String,
                        web: linksData["web"] as? String,
                        mobile: linksData["mobile"] as? String,
                        play: linksData["play"] as? String
                    )
                }
                
                return ESPNWatchStream(
                    authType: authType,
                    links: streamLinks,
                    source: source,
                    network: network
                )
            }
        }
        
        let keywords = data["keywords"] as? [String]
        let pillMetadata = data["pillMetadata"] as? [String: Any]
        let tracking = data["tracking"] as? [String: Any]
        let contentTags = data["tags"] as? [String] ?? []
        let autoplay = data["autoplay"] as? Bool
        let authType = data["authType"] as? [String]
        
        // Merge bucket tags with content tags
        let allTags = contentTags + (bucketTags ?? [])
        
        
        // Create content object with all properties
        return ESPNWatchContent(
            id: id,
            type: type,
            name: name,
            title: title,
            shortName: shortName,
            headline: headline,
            subtitle: subtitle,
            imageHref: imageHref,
            backgroundImageHref: backgroundImageHref,
            iconHref: iconHref,
            imageIcon: imageIcon,
            imageFormat: imageFormat,
            ratio: ratio,
            duration: duration,
            isLive: isLive,
            isEvent: isEvent,
            isLocked: isLocked,
            isPremium: isPremium,
            isSharePlayContent: isSharePlayContent,
            shouldTrackProgress: shouldTrackProgress,
            description: description,
            caption: caption,
            size: size,
            status: status,
            date: date,
            time: time,
            utc: utc,
            shortDate: shortDate,
            originalPublishDate: originalPublishDate,
            eventId: eventId,
            eventType: eventType,
            score: score,
            links: nil, // TODO: Parse links if needed
            catalog: data["catalog"] as? String,
            karnakCategoryId: data["karnakCategoryId"] as? String,
            karnakContentSourceId: data["karnakContentSourceId"] as? String,
            isTveOnly: isTveOnly,
            isDtcOnly: isDtcOnly,
            isPersonalized: isPersonalized,
            includeSponsor: includeSponsor,
            progress: progress,
            showKey: showKey,
            streams: parsedStreams,
            keywords: keywords,
            pillMetadata: pillMetadata,
            tracking: tracking,
            tags: allTags,
            autoplay: autoplay,
            authType: authType
        )
    }
    
    /// Converts ESPN Watch content to VideoItem
    static func convertToVideoItem(_ content: ESPNWatchContent) -> VideoItem? {
        // Determine title
        let title = content.title ?? content.name ?? content.headline ?? content.shortName
        guard let finalTitle = title, !finalTitle.isEmpty else {
            return nil
        }
        
        // Determine best image URL - prioritize background image for inline-header content
        var thumbnailURL: String?
        
        // Check if this is inline-header content by type
        if content.type?.lowercased() == "inlineheader" {
            // For inline-header content, prioritize background image
            thumbnailURL = content.backgroundImageHref ?? content.imageHref ?? content.iconHref ?? content.imageIcon
        } else {
            // For regular content, use standard priority
            thumbnailURL = content.imageHref ?? content.backgroundImageHref ?? content.iconHref
        }
        
        // For inline-header content, try to request appropriate 58:13 aspect ratio images
        if let imageURL = thumbnailURL, content.type?.lowercased() == "inlineheader" {
            // For inline-header content, request 58:13 aspect ratio (simple string append for performance)
            if imageURL.contains("espncdn.com") {
                // Simple URL manipulation without URLComponents parsing
                let separator = imageURL.contains("?") ? "&" : "?"
                thumbnailURL = "\(imageURL)\(separator)w=580&h=130&f=jpg&crop=1"
            }
        }
        
        // Essential logging for inline-header content only
        if content.type?.lowercased() == "inlineheader" {
        }
        
        // Build description
        var descriptionParts: [String] = []
        if let subtitle = content.subtitle, !subtitle.isEmpty {
            descriptionParts.append(subtitle)
        }
        if let status = content.status, !status.isEmpty {
            descriptionParts.append(status)
        }
        let description = descriptionParts.isEmpty ? nil : descriptionParts.joined(separator: " • ")
        
        // Parse publish date
        let publishDate = parseDate(from: content.date ?? content.originalPublishDate) ?? Date()
        
        // Determine sport/league (legacy fields)
        let sport = extractSportFromContent(content)
        let league = extractLeagueFromContent(content) ?? "ESPN"
        
        // Extract new metadata fields
        let network = extractNetworkFromContent(content)
        let reAir = extractReAirFromContent(content)
        let eventName = extractEventNameFromContent(content)
        
        
        // Determine if metadata should be shown (not tile-only)
        let showMetadata = !(content.tags?.contains("tile-only") == true)
        
        // Determine autoplay setting
        let autoplay = content.autoplay ?? false
        
        // Merge content tags with default tags
        let allTags = (content.tags ?? []) + ["espn", "watch"] + (content.isLive == true ? ["live"] : [])
        
        // Extract streaming URL and authType from streams
        var streamingURL: String? = nil
        var authType: [String]? = content.authType // First check content-level authType
        
        if let streams = content.streams, !streams.isEmpty {
            // For content with multiple streams, we need to find the most restrictive authType
            // and determine if any stream is available for direct playback
            var mostRestrictiveAuthType: [String] = []
            
            for stream in streams {
                let streamAuthType = stream.authType ?? []
                
                // Track the most restrictive authType across all streams
                let restrictedTypes = ["mvpd", "direct", "flagship", "isp"]
                let hasRestrictedAuth = streamAuthType.contains(where: restrictedTypes.contains)
                
                if hasRestrictedAuth && mostRestrictiveAuthType.isEmpty {
                    mostRestrictiveAuthType = streamAuthType
                }
                
                // For event-based content, all streams typically require authentication
                // Use the first stream's authType as representative
                if authType == nil {
                    authType = streamAuthType
                }
            }
            
            // Use the most restrictive authType found, or the content-level one
            if !mostRestrictiveAuthType.isEmpty {
                authType = mostRestrictiveAuthType
            }
            
            // For content with empty or no authType, try to find a playable stream URL
            if authType?.isEmpty ?? true {
                for stream in streams {
                    let streamAuthType = stream.authType ?? []
                    
                    if streamAuthType.isEmpty {
                        // For unrestricted clips/videos, try play API first (more likely to be direct stream), then web
                        if let playURL = stream.links?.play, !playURL.isEmpty {
                            streamingURL = playURL
                            break
                        } else if let webURL = stream.links?.web, !webURL.isEmpty {
                            streamingURL = webURL
                            break
                        } else if let appPlayURL = stream.links?.appPlay, !appPlayURL.isEmpty {
                            streamingURL = appPlayURL
                            break
                        }
                    }
                }
            }
        }
        
        // Determine the appropriate content ID for deep linking
        let contentId: String?
        if content.isEvent == true, let eventId = content.eventId {
            contentId = eventId
        } else {
            contentId = content.id
        }
        
        
        return VideoItem(
            title: finalTitle,
            description: description,
            thumbnailURL: thumbnailURL,
            videoURL: nil, // Keep as nil, use streamingURL instead
            duration: content.duration,
            publishedDate: publishDate,
            sport: sport,
            league: league,
            isLive: content.isLive ?? false,
            viewCount: nil,
            tags: allTags,
            autoplay: autoplay,
            showMetadata: showMetadata,
            size: content.size ?? "md", // Default to medium if not specified
            type: content.type,
            network: network,
            reAir: reAir,
            eventName: eventName,
            ratio: content.ratio,
            authType: authType,
            streamingURL: streamingURL,
            contentId: contentId,
            isEvent: content.isEvent,
            appPlayURL: extractAppPlayURL(from: content)
        )
    }
    
    /// Parse ESPN date formats
    private static func parseDate(from dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        
        let formatters = [
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd'T'HH:mm'Z'",
            "yyyy-MM-dd",
            "MM/dd/yyyy"
        ]
        
        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
    
    /// Extract sport from content
    private static func extractSportFromContent(_ content: ESPNWatchContent) -> String? {
        let title = content.title?.lowercased() ?? ""
        let name = content.name?.lowercased() ?? ""
        let combined = "\(title) \(name)"
        
        if combined.contains("nfl") || combined.contains("football") {
            return "Football"
        } else if combined.contains("nba") || combined.contains("basketball") {
            return "Basketball"
        } else if combined.contains("mlb") || combined.contains("baseball") {
            return "Baseball"
        } else if combined.contains("nhl") || combined.contains("hockey") {
            return "Hockey"
        } else if combined.contains("soccer") || combined.contains("mls") {
            return "Soccer"
        } else if combined.contains("usl") {
            return "Soccer"
        }
        
        return "General"
    }
    
    /// Parse formatted metadata from ESPN subtitle field
    private static func parseFormattedMetadata(_ subtitle: String) -> (network: String?, league: String?) {
        // ESPN API provides formatted metadata like "ESPN/ESPN+ • NCAA Baseball"
        let components = subtitle.components(separatedBy: " • ")
        
        if components.count >= 2 {
            let network = components[0].trimmingCharacters(in: .whitespaces)
            let league = components.last?.trimmingCharacters(in: .whitespaces)
            
            // Filter out generic terms from league
            if let league = league, !["General", "RE-AIR", "EN/ES", "ES"].contains(league) {
                return (network: network, league: league)
            } else {
                return (network: network, league: nil)
            }
        } else {
            // Single component, check if it's a network or league
            let cleaned = subtitle.trimmingCharacters(in: .whitespaces)
            if cleaned.contains("ESPN") || cleaned.contains("ACCN") || cleaned.contains("SECN") {
                return (network: cleaned, league: nil)
            } else {
                return (network: nil, league: cleaned)
            }
        }
    }
    
    /// Extract network information from content
    private static func extractNetworkFromContent(_ content: ESPNWatchContent) -> String? {
        // Try streams array first (likely contains network info)
        if let streams = content.streams, !streams.isEmpty {
            // Get network from first stream
            if let network = streams.first?.network {
                return network
            }
        }
        
        // Parse formatted subtitle
        if let subtitle = content.subtitle, !subtitle.isEmpty {
            let parsed = parseFormattedMetadata(subtitle)
            return parsed.network
        }
        
        return nil
    }
    
    /// Extract league/sport information for cleaner metadata display
    private static func extractLeagueFromContent(_ content: ESPNWatchContent) -> String? {
        // Parse formatted subtitle first
        if let subtitle = content.subtitle, !subtitle.isEmpty {
            let parsed = parseFormattedMetadata(subtitle)
            if let league = parsed.league {
                return league
            }
        }
        
        // Fallback to extracted sport
        return extractSportFromContent(content)
    }
    
    /// Extract re-air information from content
    private static func extractReAirFromContent(_ content: ESPNWatchContent) -> String? {
        // Check subtitle for RE-AIR indicator first
        if let subtitle = content.subtitle, subtitle.contains("RE-AIR") {
            return "Re-Air"
        }
        
        // Check if this is a repeat/re-air based on tags or other indicators
        if let tags = content.tags {
            if tags.contains("repeat") || tags.contains("reair") || tags.contains("replay") {
                return "Re-Air"
            }
        }
        
        // Check in description or other fields for re-air indicators
        if let description = content.description?.lowercased() {
            if description.contains("re-air") || description.contains("repeat") || description.contains("replay") {
                return "Re-Air"
            }
        }
        
        return nil
    }
    
    /// Extract event name from content (avoiding duplication with title and filtering out generic terms)
    private static func extractEventNameFromContent(_ content: ESPNWatchContent) -> String? {
        // Determine what's being used as the title
        let usedAsTitle = content.title ?? content.name ?? content.headline ?? content.shortName
        
        // Try eventType, but filter out generic terms
        if let eventType = content.eventType, !eventType.isEmpty, eventType != usedAsTitle {
            let lowerEventType = eventType.lowercased()
            // Skip generic event types that don't add value
            if lowerEventType != "game" && lowerEventType != "match" && lowerEventType != "event" {
                return eventType
            }
        }
        
        // If we have a specific event name that's different from the title, use it
        if let headline = content.headline, !headline.isEmpty, headline != usedAsTitle {
            return headline
        }
        
        if let shortName = content.shortName, !shortName.isEmpty, shortName != usedAsTitle {
            return shortName
        }
        
        if let name = content.name, !name.isEmpty, name != usedAsTitle {
            return name
        }
        
        // If all potential event names are the same as title, don't show event name
        return nil
    }
    
    /// Extract the ESPN app deep link URL from content streams
    private static func extractAppPlayURL(from content: ESPNWatchContent) -> String? {
        // Try to get appPlay URL from streams
        if let streams = content.streams, !streams.isEmpty {
            // For multiple streams, prefer the primary or first available appPlay URL
            for stream in streams {
                if let appPlayURL = stream.links?.appPlay, !appPlayURL.isEmpty {
                    return appPlayURL
                }
            }
        }
        return nil
    }
}
