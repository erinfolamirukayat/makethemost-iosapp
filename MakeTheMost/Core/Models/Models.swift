import Foundation

// MARK: - Enums matching Android & Backend

public enum InterceptionAction: String, Codable, CaseIterable {
    case directAppSwap = "DIRECT_APP_SWAP"
    case motivationCard = "MOTIVATION_CARD"
    
    public var displayName: String {
        switch self {
        case .directAppSwap: return "Direct App Swap"
        case .motivationCard: return "Motivation Card"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .directAppSwap:
            return "Automatically launch a helpful app (e.g., YouVersion Bible) instead"
        case .motivationCard:
            return "Display inspiring Scripture cards or custom prompt cards"
        }
    }
}

public enum EnforcementMode: String, Codable, CaseIterable {
    case makeTheMost = "MAKE_THE_MOST"
    case brutal = "BRUTAL"
    
    public var title: String {
        switch self {
        case .makeTheMost: return "MakeTheMost Mode"
        case .brutal: return "Brutal Mode"
        }
    }
    
    public var badgeText: String {
        switch self {
        case .makeTheMost: return "DAILY SCHEDULE"
        case .brutal: return "MULTI-DAY FAST"
        }
    }
}

public enum ChallengeCategory: String, Codable, CaseIterable, Identifiable {
    case physicalSquats = "PHYSICAL_SQUATS"
    case faithScripture = "FAITH_SCRIPTURE"
    case productivityQuotes = "PRODUCTIVITY_QUOTES"
    case cognitiveMath = "COGNITIVE_MATH"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .physicalSquats: return "Physical Exercise (Squats)"
        case .faithScripture: return "Faith & Scripture Typing"
        case .productivityQuotes: return "Productivity & Wisdom Quotes"
        case .cognitiveMath: return "Cognitive Mental Math"
        }
    }
    
    public var description: String {
        switch self {
        case .physicalSquats:
            return "Complete verified bodyweight squats tracked by your phone's motion sensors"
        case .faithScripture:
            return "Type out an exact NKJV Bible passage with 100% character accuracy (no copy-paste)"
        case .productivityQuotes:
            return "Reflect and type an inspiring quote on focus, deep work, and discipline"
        case .cognitiveMath:
            return "Solve mental arithmetic problems; one wrong answer resets your streak"
        }
    }
    
    public var sfSymbol: String {
        switch self {
        case .physicalSquats: return "figure.run.square.stack.fill"
        case .faithScripture: return "book.fill"
        case .productivityQuotes: return "quote.opening"
        case .cognitiveMath: return "plus.slash.minus"
        }
    }
}

public enum ChallengeDifficulty: String, Codable, CaseIterable, Identifiable {
    case easy = "EASY"
    case medium = "MEDIUM"
    case brutal = "BRUTAL"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .easy: return "Standard"
        case .medium: return "Challenging"
        case .brutal: return "Relentless"
        }
    }
    
    public var multiplierLabel: String {
        switch self {
        case .easy: return "1x Friction"
        case .medium: return "2x Friction"
        case .brutal: return "4x Friction"
        }
    }
    
    public var squatCount: Int {
        switch self {
        case .easy: return 15
        case .medium: return 30
        case .brutal: return 60
        }
    }
    
    public var mathProblemCount: Int {
        switch self {
        case .easy: return 3
        case .medium: return 5
        case .brutal: return 8
        }
    }
    
    public var timeLimitSeconds: Int {
        switch self {
        case .easy: return 90
        case .medium: return 120
        case .brutal: return 180
        }
    }
}

/// Strategy for App Swap on iOS
public enum AppSwapStrategy: String, Codable, CaseIterable {
    case defaultShield = "DEFAULT_SHIELD"
    case powerUserShortcuts = "POWER_USER_SHORTCUTS"
    
    public var title: String {
        switch self {
        case .defaultShield: return "Default Mode (Screen Time Shield)"
        case .powerUserShortcuts: return "Power-User Mode (Zero-Click Instant Swap)"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .defaultShield:
            return "Zero external setup. Displays a full-screen shield with dynamic scripture and a 1-tap swap button."
        case .powerUserShortcuts:
            return "Instant zero-tap swap using Apple Shortcuts Automation. Redirects immediately upon launch."
        }
    }
}

// MARK: - Schedule & Interception Models

public struct MakeTheMostSchedule: Identifiable, Codable, Equatable {
    public var id: String
    public var name: String
    public var isEnabled: Bool
    public var startTimeMinutes: Int // Minutes from midnight (e.g. 9:00 = 540)
    public var endTimeMinutes: Int   // Minutes from midnight (e.g. 17:00 = 1020)
    public var activeDaysOfWeek: [Int] // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
    public var challengeCategory: ChallengeCategory
    public var challengeDifficulty: ChallengeDifficulty
    public var defaultAction: InterceptionAction
    public var swapAppUrl: String
    public var swapAppLabel: String
    public var motivationCards: [String]
    public var blockedAppTokensData: Data? // Encoded FamilyActivitySelection or tokens
    
    public init(
        id: String = UUID().uuidString,
        name: String = "Focus Window",
        isEnabled: Bool = true,
        startTimeMinutes: Int = 9 * 60,
        endTimeMinutes: Int = 17 * 60,
        activeDaysOfWeek: [Int] = [2, 3, 4, 5, 6], // Mon-Fri
        challengeCategory: ChallengeCategory = .physicalSquats,
        challengeDifficulty: ChallengeDifficulty = .easy,
        defaultAction: InterceptionAction = .directAppSwap,
        swapAppUrl: String = "youversion://",
        swapAppLabel: String = "Bible App (YouVersion)",
        motivationCards: [String] = ["Pray", "Study Scripture", "Walk Outside"],
        blockedAppTokensData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.isEnabled = isEnabled
        self.startTimeMinutes = startTimeMinutes
        self.endTimeMinutes = endTimeMinutes
        self.activeDaysOfWeek = activeDaysOfWeek
        self.challengeCategory = challengeCategory
        self.challengeDifficulty = challengeDifficulty
        self.defaultAction = defaultAction
        self.swapAppUrl = swapAppUrl
        self.swapAppLabel = swapAppLabel
        self.motivationCards = motivationCards
        self.blockedAppTokensData = blockedAppTokensData
    }
}

public struct ActiveBypassReward: Codable, Equatable {
    public var targetIdentifier: String
    public var expiresAtTimestampMs: Int64
    
    public init(targetIdentifier: String, expiresAtTimestampMs: Int64) {
        self.targetIdentifier = targetIdentifier
        self.expiresAtTimestampMs = expiresAtTimestampMs
    }
    
    public var isExpired: Bool {
        Int64(Date().timeIntervalSince1970 * 1000) >= expiresAtTimestampMs
    }
    
    public var remainingSeconds: Int {
        let diffMs = expiresAtTimestampMs - Int64(Date().timeIntervalSince1970 * 1000)
        return max(0, Int(diffMs / 1000))
    }
}
