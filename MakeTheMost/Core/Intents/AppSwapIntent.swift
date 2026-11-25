import Foundation
import AppIntents
import UIKit

/// Swift AppIntent providing zero-click instant app redirection via Apple Shortcuts Automation.
/// Triggered when a distracting app (e.g. Instagram, TikTok) is opened:
/// If a focus window is currently active and not in the 15-minute reward window,
/// immediately launches the YouVersion Bible App or designated replacement app.
public struct PerformAppSwapIntent: AppIntent {
    public static var title: LocalizedStringResource = "Perform MakeTheMost App Swap"
    public static var description = IntentDescription("Checks active focus windows and instantly swaps to the YouVersion Bible App or replacement app if distracted.")
    
    public static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Target App Name", default: "Distracting App")
    public var targetAppName: String
    
    public init() {}
    
    public init(targetAppName: String) {
        self.targetAppName = targetAppName
    }
    
    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let schedules = AppGroupStorage.shared.loadSchedules()
        let decision = ScheduleEvaluator.evaluateCurrentInterception(schedules: schedules)
        
        // If in reward window, allow the user to use the app
        if decision.inRewardWindow {
            return .result(dialog: "Enjoy your focus reward break (\(decision.remainingRewardSeconds / 60)m left).")
        }
        
        // If an intentional schedule is active, perform the instant App Swap!
        if decision.shouldShield {
            let swapUrlString = decision.matchedSchedule?.swapAppUrl ?? AppGroupConstants.defaultSwapAppUrl
            if let swapUrl = URL(string: swapUrlString), UIApplication.shared.canOpenURL(swapUrl) {
                UIApplication.shared.open(swapUrl, options: [:], completionHandler: nil)
                return .result(dialog: "Redirecting to \(decision.matchedSchedule?.swapAppLabel ?? "Bible App"). Stay focused!")
            } else if let fallbackUrl = URL(string: AppGroupConstants.defaultSwapWebFallbackUrl) {
                UIApplication.shared.open(fallbackUrl, options: [:], completionHandler: nil)
                return .result(dialog: "Redirecting to Bible.com. Stay intentional!")
            }
        }
        
        // No active schedule
        return .result(dialog: "No active focus window. Enjoy your time intentionally.")
    }
}
