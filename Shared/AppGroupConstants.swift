import Foundation

/// Central constants shared across the main app and Screen Time extensions
/// via the App Group container ("group.com.makethemost.app").
public enum AppGroupConstants {
    public static let appGroupId = "group.com.makethemost.app"
    public static let appUrlScheme = "makethemost"
    
    // UserDefaults Keys
    public static let keySchedules = "mtm_schedules_json"
    public static let keyActiveBypasses = "mtm_active_bypasses_json"
    public static let keyUserAccount = "mtm_user_account_json"
    public static let keyShieldQuote = "mtm_current_shield_quote"
    public static let keyShieldScripture = "mtm_current_shield_scripture"
    public static let keyDefaultSwapAppUrl = "mtm_default_swap_app_url"
    public static let keyAppSwapMode = "mtm_app_swap_mode"
    public static let keyRewardWindowDurationSeconds = "mtm_reward_window_duration_seconds"
    public static let keyFamilyActivitySelection = "mtm_family_activity_selection"
    
    // Default Values
    public static let defaultRewardWindowSeconds: TimeInterval = 15 * 60 // 15 minutes
    public static let defaultSwapAppUrl = "youversion://" // YouVersion Bible App URL scheme
    public static let defaultSwapWebFallbackUrl = "https://www.bible.com"
    
    /// Shared UserDefaults instance backed by App Group container
    public static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupId) ?? .standard
    }
}
