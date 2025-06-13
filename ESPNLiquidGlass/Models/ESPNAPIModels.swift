import Foundation

// MARK: - API Response Models

struct NewsResponse: Codable {
    let headlines: [NewsArticle]?
    let resultsCount: Int?
    let resultsOffset: Int?
}

struct LeagueNewsResponse: Codable {
    let articles: [NewsArticle]?
}

struct NewsArticle: Codable {
    let id: Int?
    let headline: String?
    let description: String?
    let published: String?
    let byline: String?
    let type: String?
    let premium: Bool?
    let source: String?
    let links: Links?
    let images: [ArticleImage]?
    let video: [VideoContent]?
    let categories: [Category]?
    
    struct Links: Codable {
        let web: WebLink?
        let mobile: MobileLink?
        
        struct WebLink: Codable {
            let href: String?
        }
        
        struct MobileLink: Codable {
            let href: String?
        }
    }
    
    struct ArticleImage: Codable {
        let url: String?
        let width: Int?
        let height: Int?
        let caption: String?
    }
    
    struct VideoContent: Codable {
        let id: Int?
        let headline: String?
        let description: String?
        let thumbnail: String?
        let source: String?
        let duration: Int?
        let links: VideoLinks?
        
        struct VideoLinks: Codable {
            let source: VideoSource?
            
            struct VideoSource: Codable {
                let href: String?
            }
        }
    }
    
    struct Category: Codable {
        let description: String?
        let type: String?
        let sportId: Int?
        let leagueId: Int?
        let league: League?
        let uid: String?
        
        struct League: Codable {
            let description: String?
            let links: Links?
            
            struct Links: Codable {
                let web: WebLink?
                
                struct WebLink: Codable {
                    let href: String?
                }
            }
        }
    }
}

// MARK: - Sports Scores Models

struct SportGameData {
    let league: String
    let leagueName: String
    let leagueAbbreviation: String
    let icon: String
    let events: [ESPNEvent]
}

struct ESPNEvent: Codable {
    let id: String?
    let uid: String?
    let date: String?
    let name: String?
    let shortName: String?
    let season: Season?
    let competitions: [Competition]?
    let status: ESPNGameStatus?
    let venue: Venue?
    
    var isLive: Bool {
        status?.type?.state == "in"
    }
    
    var isUpcoming: Bool {
        status?.type?.state == "pre"
    }
    
    var isFinal: Bool {
        status?.type?.state == "post"
    }
    
    struct Season: Codable {
        let year: Int?
        let type: Int?
        let slug: String?
    }
    
    struct Competition: Codable {
        let id: String?
        let uid: String?
        let date: String?
        let timeValid: Bool?
        let neutralSite: Bool?
        let conferenceCompetition: Bool?
        let boxscoreAvailable: Bool?
        let commentaryAvailable: Bool?
        let liveAvailable: Bool?
        let onWatchESPN: Bool?
        let recent: Bool?
        let competitors: [Competitor]?
        let notes: [Note]?
        let situation: ESPNSituation?
        let status: ESPNGameStatus?
        let broadcasts: [ESPNBroadcast]?
        let leaders: [Leader]?
        let format: Format?
        let startDate: String?
        let geoBroadcasts: [GeoBroadcast]?
        let headlines: [Headline]?
        
        struct Competitor: Codable {
            let id: String?
            let uid: String?
            let type: String?
            let order: Int?
            let homeAway: String?
            let winner: Bool?
            let team: TeamInfo?
            let score: String?
            let linescores: [Linescore]?
            let statistics: [Statistic]?
            let leaders: [Leader]?
            let curatedRank: CuratedRank?
            let records: [Record]?
            
            struct TeamInfo: Codable {
                let id: String?
                let uid: String?
                let location: String?
                let name: String?
                let abbreviation: String?
                let displayName: String?
                let shortDisplayName: String?
                let color: String?
                let alternateColor: String?
                let isActive: Bool?
                let logo: String?
                let links: [Link]?
            }
            
            struct Record: Codable {
                let name: String?
                let abbreviation: String?
                let type: String?
                let summary: String?
            }
            
            struct Linescore: Codable {
                let value: Double?
            }
            
            struct Statistic: Codable {
                let name: String?
                let abbreviation: String?
                let displayValue: String?
            }
            
            struct CuratedRank: Codable {
                let current: Int?
            }
            
            struct Link: Codable {
                let rel: [String]?
                let href: String?
            }
        }
        
        struct Note: Codable {
            let type: String?
            let headline: String?
        }
        
        struct Leader: Codable {
            let name: String?
            let displayName: String?
            let shortDisplayName: String?
            let abbreviation: String?
            let leaders: [LeaderDetail]?
            
            struct LeaderDetail: Codable {
                let displayValue: String?
                let value: Double?
                let athlete: Athlete?
                let team: Team?
                
                struct Athlete: Codable {
                    let id: String?
                    let fullName: String?
                    let displayName: String?
                    let shortName: String?
                    let links: [Link]?
                    let headshot: String?
                    let jersey: String?
                    let position: Position?
                    let team: Team?
                    
                    struct Position: Codable {
                        let abbreviation: String?
                    }
                }
                
                struct Team: Codable {
                    let id: String?
                }
                
                struct Link: Codable {
                    let rel: [String]?
                    let href: String?
                }
            }
        }
        
        struct Format: Codable {
            let regulation: Regulation?
            
            struct Regulation: Codable {
                let periods: Int?
            }
        }
        
        struct GeoBroadcast: Codable {
            let type: BroadcastType?
            let market: Market?
            let media: Media?
            let lang: String?
            let region: String?
            
            struct BroadcastType: Codable {
                let id: String?
                let shortName: String?
            }
            
            struct Market: Codable {
                let id: String?
                let type: String?
            }
            
            struct Media: Codable {
                let shortName: String?
            }
        }
        
        struct Headline: Codable {
            let description: String?
            let type: String?
            let shortLinkText: String?
        }
    }
    
    struct Venue: Codable {
        let id: String?
        let fullName: String?
        let address: Address?
        let capacity: Int?
        let indoor: Bool?
        
        struct Address: Codable {
            let city: String?
            let state: String?
        }
    }
}

struct ESPNGameStatus: Codable {
    let clock: Double?
    let displayClock: String?
    let period: Int?
    let type: StatusType?
    
    struct StatusType: Codable {
        let id: String?
        let name: String?
        let state: String?
        let completed: Bool?
        let description: String?
        let detail: String?
        let shortDetail: String?
    }
}

struct ESPNSituation: Codable {
    let lastPlay: ESPNLastPlay?
    let down: Int?
    let yardLine: Int?
    let distance: Int?
    let downDistanceText: String?
    let shortDownDistanceText: String?
    let possessionText: String?
    let isRedZone: Bool?
}

struct ESPNLastPlay: Codable {
    let id: String?
    let type: ESPNPlayType?
    let text: String?
}

struct ESPNPlayType: Codable {
    let id: String?
    let text: String?
}

struct ESPNBroadcast: Codable {
    let market: String?
    let names: [String]?
}

// MARK: - Scoreboard Response

struct ScoreboardResponse: Codable {
    let leagues: [League]?
    let events: [ESPNEvent]?
    
    struct League: Codable {
        let id: String?
        let uid: String?
        let name: String?
        let abbreviation: String?
        let slug: String?
        let season: Season?
        let logos: [Logo]?
        
        struct Season: Codable {
            let year: Int?
            let startDate: String?
            let endDate: String?
            let displayName: String?
            let type: SeasonType?
            
            struct SeasonType: Codable {
                let id: String?
                let type: Int?
                let name: String?
                let abbreviation: String?
            }
        }
        
        struct Logo: Codable {
            let href: String?
            let width: Int?
            let height: Int?
            let alt: String?
            let rel: [String]?
            let lastUpdated: String?
        }
    }
}