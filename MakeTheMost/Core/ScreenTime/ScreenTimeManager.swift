import Foundation
import Combine
import FamilyControls
import ManagedSettings
import DeviceActivity

/// Primary coordinator for FamilyControls, ManagedSettings, and DeviceActivity monitoring.
public final class ScreenTimeManager: ObservableObject {
    public static let shared = ScreenTimeManager()
    
    @Published public private(set) var isAuthorized: Bool = false
    @Published public var activitySelection = FamilyActivitySelection()
    @Published public private(set) var isShieldActive: Bool = false
    @Published public private(set) var rewardWindowRemainingSeconds: Int = 0
    
    private let managedStore = ManagedSettingsStore()
    private let activityCenter = DeviceActivityCenter()
    private var rewardTimer: AnyCancellable?
    
    private init() {
        checkAuthorizationStatus()
        loadPersistedSelection()
        startRewardWindowTicker()
    }
    
    // MARK: - Authorization
    
    public func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            await MainActor.run {
                self.isAuthorized = (AuthorizationCenter.shared.authorizationStatus == .approved)
            }
        } catch {
            print("ScreenTimeManager: Authorization failed with error: \(error.localizedDescription)")
            await MainActor.run {
                self.isAuthorized = false
            }
        }
    }
    
    public func checkAuthorizationStatus() {
        self.isAuthorized = (AuthorizationCenter.shared.authorizationStatus == .approved)
    }
    
    // MARK: - Selection Persistence
    
    private func loadPersistedSelection() {
        if let saved = AppGroupStorage.shared.loadFamilyActivitySelection() {
            self.activitySelection = saved
        }
    }
    
    public func updateSelection(_ newSelection: FamilyActivitySelection) {
        self.activitySelection = newSelection
        AppGroupStorage.shared.saveFamilyActivitySelection(newSelection)
        evaluateAndApplyShields()
    }
    
    // MARK: - Shield Management
    
    public func evaluateAndApplyShields() {
        let schedules = AppGroupStorage.shared.loadSchedules()
        let decision = ScheduleEvaluator.evaluateCurrentInterception(schedules: schedules)
        
        if decision.inRewardWindow {
            // Reward window active: lift shields temporarily
            liftShields()
            return
        }
        
        if decision.shouldShield {
            applyShields()
        } else {
            liftShields()
        }
    }
    
    public func applyShields() {
        guard !activitySelection.applicationTokens.isEmpty || !activitySelection.categoryTokens.isEmpty else {
            return
        }
        
        // Update shared shield configuration with dynamic Scripture or motivation
        let randomPrompt = NkjvScriptureLibrary.randomPrompt(difficulty: .easy)
        let shieldConfig = SharedShieldConfig(
            title: "Take a Breath",
            scriptureText: randomPrompt.text,
            scriptureReference: randomPrompt.reference,
            swapAppButtonTitle: "Open Bible App",
            swapAppUrlScheme: AppGroupConstants.defaultSwapAppUrl,
            challengeButtonTitle: "Breakout Challenge"
        )
        AppGroupStorage.shared.updateShieldConfig(shieldConfig)
        
        // Apply shield to selected apps and categories
        managedStore.shield.applications = activitySelection.applicationTokens
        managedStore.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(activitySelection.categoryTokens)
        
        DispatchQueue.main.async {
            self.isShieldActive = true
        }
    }
    
    public func liftShields() {
        managedStore.shield.applications = nil
        managedStore.shield.applicationCategories = nil
        managedStore.shield.webDomains = nil
        
        DispatchQueue.main.async {
            self.isShieldActive = false
        }
    }
    
    // MARK: - 15-Minute Reward Window
    
    public func activate15MinuteRewardWindow() {
        AppGroupStorage.shared.grant15MinuteRewardWindow()
        liftShields()
        startRewardWindowTicker()
    }
    
    private func startRewardWindowTicker() {
        rewardTimer?.cancel()
        rewardTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let remaining = AppGroupStorage.shared.remainingRewardSeconds()
                self.rewardWindowRemainingSeconds = remaining
                
                if remaining <= 0 && !self.isShieldActive {
                    // Reward window expired: re-evaluate schedules
                    self.evaluateAndApplyShields()
                }
            }
    }
    
    // MARK: - DeviceActivity Monitoring Schedule Registration
    
    public func registerSchedulesWithDeviceActivity(schedules: [MakeTheMostSchedule]) {
        activityCenter.stopMonitoring()
        
        for schedule in schedules where schedule.isEnabled {
            let startHour = schedule.startTimeMinutes / 60
            let startMinute = schedule.startTimeMinutes % 60
            let endHour = schedule.endTimeMinutes / 60
            let endMinute = schedule.endTimeMinutes % 60
            
            let startComponents = DateComponents(hour: startHour, minute: startMinute)
            let endComponents = DateComponents(hour: endHour, minute: endMinute)
            
            let activitySchedule = DeviceActivitySchedule(
                intervalStart: startComponents,
                intervalEnd: endComponents,
                repeats: true
            )
            
            let activityName = DeviceActivityName(schedule.id)
            do {
                try activityCenter.startMonitoring(activityName, during: activitySchedule)
            } catch {
                print("Failed to register schedule with DeviceActivityCenter: \(error)")
            }
        }
    }
}
