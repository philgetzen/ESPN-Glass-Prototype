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
    let streams: [String]?
    let keywords: [String]?
    let pillMetadata: [String: Any]?
    let tracking: [String: Any]?
    let tags: [String]?
    let autoplay: Bool?
}

struct ESPNWatchLink {
    let url: String?
    let type: String?
    let rel: String?
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
                print("❌ Could not parse JSON response")
                return nil
            }
            
            print("📊 ESPN Watch API response keys: \(Array(json.keys))")
            
            var buckets: [ESPNWatchBucket] = []
            
            // Look for buckets in page object
            if let page = json["page"] as? [String: Any],
               let bucketsArray = page["buckets"] as? [[String: Any]] {
                
                print("🪣 Found \(bucketsArray.count) buckets in page object")
                
                for (index, bucketData) in bucketsArray.enumerated() {
                    let bucketName = bucketData["name"] as? String ?? "Bucket \(index)"
                    let bucketTags = bucketData["tags"] as? [String]
                    print("🪣 Processing bucket: '\(bucketName)' with tags: \(bucketTags ?? [])")
                    
                    var contents: [ESPNWatchContent] = []
                    
                    if let contentsArray = bucketData["contents"] as? [[String: Any]] {
                        print("📦 Found \(contentsArray.count) items in bucket '\(bucketName)'")
                        
                        for contentData in contentsArray {
                            if let content = parseContent(from: contentData, bucketTags: bucketTags) {
                                contents.append(content)
                            }
                        }
                    }
                    
                    buckets.append(ESPNWatchBucket(name: bucketName, contents: contents, tags: bucketTags))
                    print("✅ Parsed bucket '\(bucketName)' with \(contents.count) items")
                }
            }
            
            let page = ESPNWatchPage(buckets: buckets)
            return ESPNWatchAPIResponse(page: page)
            
        } catch {
            print("❌ Manual parsing failed: \(error)")
            return nil
        }
    }
    
    /// Parses individual content item
    private static func parseContent(from data: [String: Any], bucketTags: [String]? = nil) -> ESPNWatchContent? {
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
        let backgroundImageHref = data["backgroundImageHref"] as? String
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
        let streams = data["streams"] as? [String]
        let keywords = data["keywords"] as? [String]
        let pillMetadata = data["pillMetadata"] as? [String: Any]
        let tracking = data["tracking"] as? [String: Any]
        let contentTags = data["tags"] as? [String] ?? []
        let autoplay = data["autoplay"] as? Bool
        
        // Merge bucket tags with content tags
        let allTags = contentTags + (bucketTags ?? [])
        
        // Essential logging for inline-header buckets only
        if bucketTags?.contains("inline-header") == true {
            print("🏷️ INLINE-HEADER BUCKET: '\(title ?? name ?? "unknown")' - Type: \(data["type"] ?? "nil")")
        }
        
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
            streams: streams,
            keywords: keywords,
            pillMetadata: pillMetadata,
            tracking: tracking,
            tags: allTags,
            autoplay: autoplay
        )
    }
    
    /// Converts ESPN Watch content to VideoItem
    static func convertToVideoItem(_ content: ESPNWatchContent) -> VideoItem? {
        // Determine title
        let title = content.title ?? content.name ?? content.headline ?? content.shortName
        guard let finalTitle = title, !finalTitle.isEmpty else {
            print("❌ No title found for content: \(content.id ?? "unknown")")
            return nil
        }
        
        // Determine best image URL - prioritize background image for inline-header content
        var thumbnailURL: String?
        
        // Check if this is inline-header content by type
        if content.type?.lowercased() == "inlineheader" {
            // For inline-header content, prioritize background image
            thumbnailURL = content.backgroundImageHref ?? content.imageHref ?? content.iconHref ?? content.imageIcon
            print("🖼️ Inline-header content detected (type: \(content.type ?? "nil"))")
            print("🖼️ Using background image priority for inline-header")
        } else {
            // For regular content, use standard priority
            thumbnailURL = content.imageHref ?? content.backgroundImageHref ?? content.iconHref
        }
        
        // For inline-header content, try to request appropriate 58:13 aspect ratio images
        if let imageURL = thumbnailURL, content.type?.lowercased() == "inlineheader" {
            // For inline-header content, request 58:13 aspect ratio (approximately 4.46:1)
            if imageURL.contains("espncdn.com") {
                var urlComponents = URLComponents(string: imageURL)
                var queryItems = urlComponents?.queryItems ?? []
                
                // Remove existing sizing params
                queryItems.removeAll { item in
                    ["w", "width", "h", "height", "f", "crop"].contains(item.name.lowercased())
                }
                
                // Add 58:13 aspect ratio sizing (e.g., 580x130 for good quality)
                queryItems.append(URLQueryItem(name: "w", value: "580"))
                queryItems.append(URLQueryItem(name: "h", value: "130"))
                queryItems.append(URLQueryItem(name: "f", value: "jpg"))
                queryItems.append(URLQueryItem(name: "crop", value: "1"))
                
                urlComponents?.queryItems = queryItems
                thumbnailURL = urlComponents?.url?.absoluteString ?? imageURL
                print("🖼️ Modified inline-header image URL for 58:13 ratio: \(thumbnailURL ?? "nil")")
            }
        }
        
        // Essential logging for inline-header content only
        if content.type?.lowercased() == "inlineheader" {
            print("🖼️ INLINE-HEADER: \(content.title ?? content.name ?? "unknown")")
            print("🖼️   Type: \(content.type ?? "nil")")
            print("🖼️   backgroundImageHref: \(content.backgroundImageHref ?? "nil")")
            print("🖼️   Final thumbnailURL: \(thumbnailURL ?? "nil")")
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
        
        return VideoItem(
            title: finalTitle,
            description: description,
            thumbnailURL: thumbnailURL,
            videoURL: nil, // ESPN doesn't expose direct URLs
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
            ratio: content.ratio
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
            return streams.first
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
}