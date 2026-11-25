import Foundation
import ManagedSettings

/// Handles user interactions on the Screen Time shield buttons.
public class ShieldActionExtension: ShieldActionDelegate {
    
    public override func handle(
        action: ShieldAction,
        for application: Application,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handleAction(action: action, completionHandler: completionHandler)
    }
    
    public override func handle(
        action: ShieldAction,
        for webDomain: WebDomain,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handleAction(action: action, completionHandler: completionHandler)
    }
    
    public override func handle(
        action: ShieldAction,
        for category: ActivityCategory,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handleAction(action: action, completionHandler: completionHandler)
    }
    
    private func handleAction(
        action: ShieldAction,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            // 1-Tap App Swap: User tapped "Open Bible App" / Swap App
            let config = AppGroupStorage.shared.loadShieldConfig()
            if let swapUrl = URL(string: config.swapAppUrlScheme) {
                // In iOS, extensions can post a shared flag or request system open
                AppGroupConstants.sharedDefaults.set(true, forKey: "mtm_pending_swap_request")
            }
            completionHandler(.close)
            
        case .secondaryButtonPressed:
            // Breakout Challenge: User wants to earn a 15-minute unshield window
            // Direct user to MakeTheMost breakout challenge
            AppGroupConstants.sharedDefaults.set(true, forKey: "mtm_pending_breakout_request")
            completionHandler(.close)
            
        @unknown default:
            completionHandler(.close)
        }
    }
}
