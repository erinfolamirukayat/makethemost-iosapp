import Foundation
import Combine
import SwiftUI

public final class AppState: ObservableObject {
    @Published public var schedules: [MakeTheMostSchedule] = []
    @Published public var userAccount: UserAccount?
    @Published public var activeTab: Int = 0
    @Published public var activeChallengeToPresent: ChallengeCategory? = nil
    @Published public var isBreakoutSheetPresented: Bool = false
    @Published public var isRewardCelebrationPresented: Bool = false
    @Published public var showShortcutsGuideSheet: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        loadData()
        setupListeners()
    }
    
    public func loadData() {
        self.schedules = AppGroupStorage.shared.loadSchedules()
        self.userAccount = AppGroupStorage.shared.loadUserAccount()
    }
    
    private func setupListeners() {
        // Observe ScreenTimeManager changes
        ScreenTimeManager.shared.$rewardWindowRemainingSeconds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] remaining in
                if remaining == 0 && self?.isRewardCelebrationPresented == true {
                    self?.isRewardCelebrationPresented = false
                }
            }
            .store(in: &cancellables)
    }
    
    public func saveSchedules(_ newSchedules: [MakeTheMostSchedule]) {
        self.schedules = newSchedules
        AppGroupStorage.shared.saveSchedules(newSchedules)
        ScreenTimeManager.shared.evaluateAndApplyShields()
        ScreenTimeManager.shared.registerSchedulesWithDeviceActivity(schedules: newSchedules)
        
        // Sync schedules to cloud if user is signed in
        if let account = userAccount {
            Task {
                _ = try? await NeonAPIClient.shared.syncSchedules(account: account, schedules: newSchedules)
            }
        }
    }
    
    public func handleOpenURL(_ url: URL) {
        guard url.scheme == AppGroupConstants.appUrlScheme else { return }
        
        switch url.host {
        case "breakout":
            // Directly trigger Breakout Challenge modal
            self.activeChallengeToPresent = schedules.first?.challengeCategory ?? .physicalSquats
            self.isBreakoutSheetPresented = true
            
        case "swap":
            // Instant swap fallback if opened via custom URL
            let swapUrlString = schedules.first?.swapAppUrl ?? AppGroupConstants.defaultSwapAppUrl
            if let swapUrl = URL(string: swapUrlString) {
                UIApplication.shared.open(swapUrl)
            }
            
        default:
            break
        }
    }
    
    public func completeBreakoutChallenge() {
        ScreenTimeManager.shared.activate15MinuteRewardWindow()
        self.isBreakoutSheetPresented = false
        self.isRewardCelebrationPresented = true
    }
}
