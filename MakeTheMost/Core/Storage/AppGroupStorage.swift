import Foundation
import FamilyControls

/// Manages data persistence in the shared App Group UserDefaults container
/// so both the main app and Screen Time extensions have immediate synchronized access.
public final class AppGroupStorage {
    public static let shared = AppGroupStorage()
    private let defaults = AppGroupConstants.sharedDefaults
    
    private init() {}
    
    // MARK: - Schedules
    
    public func loadSchedules() -> [MakeTheMostSchedule] {
        guard let data = defaults.data(forKey: AppGroupConstants.keySchedules),
              let list = try? JSONDecoder().decode([MakeTheMostSchedule].self, from: data) else {
            return [defaultSchedule()]
        }
        return list.isEmpty ? [defaultSchedule()] : list
    }
    
    public func saveSchedules(_ schedules: [MakeTheMostSchedule]) {
        if let data = try? JSONEncoder().encode(schedules) {
            defaults.set(data, forKey: AppGroupConstants.keySchedules)
        }
    }
    
    public func defaultSchedule() -> MakeTheMostSchedule {
        MakeTheMostSchedule(
            id: "default_work_focus",
            name: "Daily Work Focus",
            isEnabled: true,
            startTimeMinutes: 9 * 60,   // 9:00 AM
            endTimeMinutes: 17 * 60,   // 5:00 PM
            activeDaysOfWeek: [2, 3, 4, 5, 6], // Monday to Friday
            challengeCategory: .physicalSquats,
            challengeDifficulty: .easy,
            defaultAction: .directAppSwap,
            swapAppUrl: AppGroupConstants.defaultSwapAppUrl,
            swapAppLabel: "Bible App (YouVersion)",
            motivationCards: ["Pray & Reflect", "Read Scripture", "Deep Work Focus"]
        )
    }
    
    // MARK: - User Account
    
    public func loadUserAccount() -> UserAccount? {
        guard let data = defaults.data(forKey: AppGroupConstants.keyUserAccount),
              let account = try? JSONDecoder().decode(UserAccount.self, from: data) else {
            return nil
        }
        return account
    }
    
    public func saveUserAccount(_ account: UserAccount) {
        if let data = try? JSONEncoder().encode(account) {
            defaults.set(data, forKey: AppGroupConstants.keyUserAccount)
        }
    }
    
    public func clearUserAccount() {
        defaults.removeObject(forKey: AppGroupConstants.keyUserAccount)
    }
    
    // MARK: - 15-Minute Reward Window / Active Bypasses
    
    public func getActiveBypasses() -> [String: ActiveBypassReward] {
        guard let data = defaults.data(forKey: AppGroupConstants.keyActiveBypasses),
              let map = try? JSONDecoder().decode([String: ActiveBypassReward].self, from: data) else {
            return [:]
        }
        // Filter out expired bypasses
        return map.filter { !$0.value.isExpired }
    }
    
    public func grant15MinuteRewardWindow(targetIdentifier: String = "ALL_APPS") {
        var current = getActiveBypasses()
        let expiresAtMs = Int64(Date().addingTimeInterval(AppGroupConstants.defaultRewardWindowSeconds).timeIntervalSince1970 * 1000)
        current[targetIdentifier] = ActiveBypassReward(
            targetIdentifier: targetIdentifier,
            expiresAtTimestampMs: expiresAtMs
        )
        if let data = try? JSONEncoder().encode(current) {
            defaults.set(data, forKey: AppGroupConstants.keyActiveBypasses)
        }
    }
    
    public func isRewardWindowActive(targetIdentifier: String = "ALL_APPS") -> Bool {
        let bypasses = getActiveBypasses()
        if let global = bypasses["ALL_APPS"], !global.isExpired {
            return true
        }
        if let specific = bypasses[targetIdentifier], !specific.isExpired {
            return true
        }
        return false
    }
    
    public func remainingRewardSeconds(targetIdentifier: String = "ALL_APPS") -> Int {
        let bypasses = getActiveBypasses()
        if let global = bypasses["ALL_APPS"], !global.isExpired {
            return global.remainingSeconds
        }
        if let specific = bypasses[targetIdentifier], !specific.isExpired {
            return specific.remainingSeconds
        }
        return 0
    }
    
    // MARK: - App Swap Strategy
    
    public var appSwapStrategy: AppSwapStrategy {
        get {
            let raw = defaults.string(forKey: AppGroupConstants.keyAppSwapMode) ?? AppSwapStrategy.defaultShield.rawValue
            return AppSwapStrategy(rawValue: raw) ?? .defaultShield
        }
        set {
            defaults.set(newValue.rawValue, forKey: AppGroupConstants.keyAppSwapMode)
        }
    }
    
    // MARK: - Shared Shield Configuration
    
    public func loadShieldConfig() -> SharedShieldConfig {
        guard let data = defaults.data(forKey: "mtm_shared_shield_config"),
              let config = try? JSONDecoder().decode(SharedShieldConfig.self, from: data) else {
            return SharedShieldConfig()
        }
        return config
    }
    
    public func updateShieldConfig(_ config: SharedShieldConfig) {
        if let data = try? JSONEncoder().encode(config) {
            defaults.set(data, forKey: "mtm_shared_shield_config")
        }
    }
    
    // MARK: - Family Activity Selection Persistence
    
    public func saveFamilyActivitySelection(_ selection: FamilyActivitySelection) {
        if let data = try? JSONEncoder().encode(selection) {
            defaults.set(data, forKey: AppGroupConstants.keyFamilyActivitySelection)
        }
    }
    
    public func loadFamilyActivitySelection() -> FamilyActivitySelection? {
        guard let data = defaults.data(forKey: AppGroupConstants.keyFamilyActivitySelection),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return nil
        }
        return selection
    }
}
