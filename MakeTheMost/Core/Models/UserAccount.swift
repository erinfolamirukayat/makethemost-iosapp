import Foundation

public struct UserAccount: Codable, Equatable {
    public var id: String
    public var fullName: String
    public var email: String
    public var partnerEmail: String
    public var passwordHash: String
    public var createdAtMs: Int64
    public var schedulesJson: String?
    public var motivationCardsJson: String?
    
    public init(
        id: String = "usr_\(UUID().uuidString.prefix(8))",
        fullName: String = "Member",
        email: String = "",
        partnerEmail: String = "",
        passwordHash: String = "",
        createdAtMs: Int64 = Int64(Date().timeIntervalSince1970 * 1000),
        schedulesJson: String? = nil,
        motivationCardsJson: String? = nil
    ) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.partnerEmail = partnerEmail
        self.passwordHash = passwordHash
        self.createdAtMs = createdAtMs
        self.schedulesJson = schedulesJson
        self.motivationCardsJson = motivationCardsJson
    }
    
    public var membershipBadge: String {
        "100% Free Member"
    }
}

public struct DailyComplianceSummary: Codable, Equatable {
    public var dateIso: String
    public var makeTheMostScheduledMinutes: Int
    public var makeTheMostBypassedMinutes: Int
    public var brutalFastScheduledMinutes: Int
    public var brutalFastBrokenMinutes: Int
    
    public init(
        dateIso: String,
        makeTheMostScheduledMinutes: Int = 0,
        makeTheMostBypassedMinutes: Int = 0,
        brutalFastScheduledMinutes: Int = 0,
        brutalFastBrokenMinutes: Int = 0
    ) {
        self.dateIso = dateIso
        self.makeTheMostScheduledMinutes = makeTheMostScheduledMinutes
        self.makeTheMostBypassedMinutes = makeTheMostBypassedMinutes
        self.brutalFastScheduledMinutes = brutalFastScheduledMinutes
        self.brutalFastBrokenMinutes = brutalFastBrokenMinutes
    }
}
