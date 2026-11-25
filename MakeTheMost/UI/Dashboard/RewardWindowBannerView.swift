import SwiftUI

public struct RewardWindowBannerView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var appState: AppState
    
    public var body: some View {
        if screenTimeManager.rewardWindowRemainingSeconds > 0 {
            HStack(spacing: 14) {
                Image(systemName: "timer")
                    .font(.title2)
                    .foregroundColor(Theme.warmAmber)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("15-Min Shield Reward Active")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("\(formattedRemainingTime) remaining before shields restore")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                Text(formattedRemainingTime)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.electricEmerald)
            }
            .padding(16)
            .background(Theme.elevatedSlate)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.warmAmber.opacity(0.6), lineWidth: 1.5)
            )
        }
    }
    
    private var formattedRemainingTime: String {
        let seconds = screenTimeManager.rewardWindowRemainingSeconds
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
