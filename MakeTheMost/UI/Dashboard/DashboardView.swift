import SwiftUI
import FamilyControls

public struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var selectedScheduleForEdit: MakeTheMostSchedule?
    @State private var showActivityPicker: Bool = false
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Screen Time Permission Callout (if needed)
                    if !screenTimeManager.isAuthorized {
                        ScreenTimePermissionCard()
                    }
                    
                    // Reward Window Countdown Banner (if active)
                    RewardWindowBannerView()
                    
                    // Main Status Card
                    MainStatusCard()
                    
                    // Schedules Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Focus Schedules")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.textPrimary)
                            
                            Spacer()
                            
                            Button(action: {
                                let newSchedule = MakeTheMostSchedule(
                                    name: "New Focus Schedule",
                                    startTimeMinutes: 9 * 60,
                                    endTimeMinutes: 17 * 60
                                )
                                selectedScheduleForEdit = newSchedule
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(Theme.electricEmerald)
                            }
                        }
                        
                        if appState.schedules.isEmpty {
                            Text("No focus schedules configured. Tap + to add one.")
                                .font(.subheadline)
                                .foregroundColor(Theme.textMuted)
                                .padding(.vertical, 20)
                        } else {
                            ForEach(appState.schedules) { schedule in
                                ScheduleCardView(
                                    schedule: schedule,
                                    onEdit: {
                                        selectedScheduleForEdit = schedule
                                    },
                                    onTriggerBreakout: {
                                        appState.activeChallengeToPresent = schedule.challengeCategory
                                        appState.isBreakoutSheetPresented = true
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Theme.deepObsidian.ignoresSafeArea())
            .navigationTitle("MakeTheMost")
            .sheet(item: $selectedScheduleForEdit) { schedule in
                ScheduleEditView(schedule: schedule) { updated in
                    if let idx = appState.schedules.firstIndex(where: { $0.id == updated.id }) {
                        var list = appState.schedules
                        list[idx] = updated
                        appState.saveSchedules(list)
                    } else {
                        var list = appState.schedules
                        list.append(updated)
                        appState.saveSchedules(list)
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

struct MainStatusCard: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(screenTimeManager.isShieldActive ? Theme.electricEmerald.opacity(0.2) : Theme.elevatedSlate)
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: screenTimeManager.isShieldActive ? "shield.fill" : "shield.slash")
                        .font(.title2)
                        .foregroundColor(screenTimeManager.isShieldActive ? Theme.electricEmerald : Theme.textMuted)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(screenTimeManager.isShieldActive ? "Shields Active & Armed" : "Ready & Monitoring")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text(screenTimeManager.isShieldActive ? "Distracting apps are shielded" : "Focus windows will engage automatically")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
            }
            
            Divider()
                .background(Theme.subtleBorder)
            
            HStack(spacing: 12) {
                Button(action: {
                    appState.activeChallengeToPresent = appState.schedules.first?.challengeCategory ?? .physicalSquats
                    appState.isBreakoutSheetPresented = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "figure.run")
                        Text("Breakout Challenge")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.warmAmber)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Theme.warmAmber.opacity(0.12))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    appState.activeTab = 2 // Jump to App Swap settings
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.swap")
                        Text("App Swap Mode")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Theme.elevatedSlate)
                    .cornerRadius(8)
                }
            }
        }
        .padding(18)
        .frostedCardStyle()
    }
}


struct ScreenTimePermissionCard: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "exclamationmark.shield.fill")
                    .foregroundColor(Theme.warmAmber)
                Text("Screen Time Access Required")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
            }
            
            Text("Apple requires Screen Time permission to enable app interception and Shields.")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            
            Button("Grant Screen Time Permission") {
                Task {
                    await screenTimeManager.requestAuthorization()
                }
            }
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(Color(hex: 0x032218))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Theme.warmAmber)
            .cornerRadius(8)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.warmAmber.opacity(0.12))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.warmAmber.opacity(0.4), lineWidth: 1)
        )
    }
}
