import SwiftUI

public struct ChallengeSuccessView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            // Celebration Icon
            ZStack {
                Circle()
                    .fill(Theme.electricEmerald.opacity(0.15))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 72))
                    .foregroundColor(Theme.electricEmerald)
            }
            
            VStack(spacing: 8) {
                Text("Challenge Conquered!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                
                Text("You broke the trance through intentional effort.")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // 15-Minute Countdown Box
            VStack(spacing: 8) {
                Text("15-MINUTE REWARD WINDOW ACTIVE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.warmAmber)
                    .tracking(2)
                
                Text(formattedTime(screenTimeManager.rewardWindowRemainingSeconds))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.electricEmerald)
                
                Text("Shields will automatically snap back when the timer finishes.")
                    .font(.caption2)
                    .foregroundColor(Theme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .frostedCardStyle()
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: openSwapApp) {
                    HStack {
                        Image(systemName: "book.fill")
                        Text("Open Bible App")
                    }
                    .primaryButtonStyle()
                }
                
                Button("Return to Dashboard") {
                    dismiss()
                }
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .background(Theme.deepObsidian.ignoresSafeArea())
    }
    
    private func formattedTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private func openSwapApp() {
        dismiss()
        let urlString = appState.schedules.first?.swapAppUrl ?? AppGroupConstants.defaultSwapAppUrl
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
