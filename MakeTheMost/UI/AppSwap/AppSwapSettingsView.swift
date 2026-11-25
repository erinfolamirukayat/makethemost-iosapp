import SwiftUI

public struct AppSwapSettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedStrategy: AppSwapStrategy
    @State private var targetAppLabel: String
    @State private var targetAppUrl: String
    @State private var showGuideSheet: Bool = false
    
    public init() {
        let currentStrategy = AppGroupStorage.shared.appSwapStrategy
        let defaultSchedule = AppGroupStorage.shared.loadSchedules().first
        _selectedStrategy = State(initialValue: currentStrategy)
        _targetAppLabel = State(initialValue: defaultSchedule?.swapAppLabel ?? "Bible App (YouVersion)")
        _targetAppUrl = State(initialValue: defaultSchedule?.swapAppUrl ?? AppGroupConstants.defaultSwapAppUrl)
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "arrow.triangle.swap")
                                .font(.title2)
                                .foregroundColor(Theme.electricEmerald)
                            Text("MakeTheMost Signature App Swap")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)
                        }
                        
                        Text("Instead of losing hours down social media rabbit holes, instantly route your attention toward scripture, prayer, and deep focus.")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                    .padding(16)
                    .frostedCardStyle()
                    
                    // Strategy Selection Cards
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Choose App Swap Strategy")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        
                        // Default Mode Card
                        StrategyCard(
                            strategy: .defaultShield,
                            isSelected: selectedStrategy == .defaultShield,
                            badge: "ZERO EXTERNAL SETUP",
                            title: "Default Mode (Screen Time Shield)",
                            description: "Presents a full-screen shield over distracting apps featuring dynamic Scripture and an instant 1-tap button to launch the Bible App.",
                            onSelect: {
                                selectedStrategy = .defaultShield
                                AppGroupStorage.shared.appSwapStrategy = .defaultShield
                            }
                        )
                        
                        // Power User Mode Card
                        StrategyCard(
                            strategy: .powerUserShortcuts,
                            isSelected: selectedStrategy == .powerUserShortcuts,
                            badge: "ZERO-CLICK REDIRECTION",
                            title: "Power-User Mode (Apple Shortcuts)",
                            description: "Uses Apple Shortcuts Automation. When you tap Instagram or TikTok, iOS immediately redirects you straight to the Bible App with zero taps required.",
                            onSelect: {
                                selectedStrategy = .powerUserShortcuts
                                AppGroupStorage.shared.appSwapStrategy = .powerUserShortcuts
                                showGuideSheet = true
                            }
                        )
                    }
                    
                    if selectedStrategy == .powerUserShortcuts {
                        Button(action: {
                            showGuideSheet = true
                        }) {
                            HStack {
                                Image(systemName: "gearshape.arrow.triangle.2.circlepath")
                                Text("View Shortcuts Automation Setup Guide")
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.warmAmber)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Theme.warmAmber.opacity(0.12))
                            .cornerRadius(10)
                        }
                    }
                    
                    // Destination App Configuration
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Replacement App Destination")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("App Label:")
                                    .font(.caption)
                                    .foregroundColor(Theme.textMuted)
                                    .frame(width: 90, alignment: .leading)
                                TextField("Bible App (YouVersion)", text: $targetAppLabel)
                                    .font(.subheadline)
                                    .foregroundColor(Theme.textPrimary)
                            }
                            
                            Divider().background(Theme.subtleBorder)
                            
                            HStack {
                                Text("URL Scheme:")
                                    .font(.caption)
                                    .foregroundColor(Theme.textMuted)
                                    .frame(width: 90, alignment: .leading)
                                TextField("youversion://", text: $targetAppUrl)
                                    .font(.subheadline)
                                    .foregroundColor(Theme.textPrimary)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                            }
                        }
                        .padding(16)
                        .frostedCardStyle()
                    }
                    
                    // Test Button
                    Button(action: testSwapApp) {
                        HStack {
                            Image(systemName: "arrow.up.right.square")
                            Text("Test Launch Replacement App")
                        }
                        .primaryButtonStyle()
                    }
                }
                .padding(20)
            }
            .background(Theme.deepObsidian.ignoresSafeArea())
            .navigationTitle("App Swap")
            .sheet(isPresented: $showGuideSheet) {
                ShortcutsSetupGuideView()
            }
        }
    }
    
    private func testSwapApp() {
        if let url = URL(string: targetAppUrl), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let fallbackUrl = URL(string: AppGroupConstants.defaultSwapWebFallbackUrl) {
            UIApplication.shared.open(fallbackUrl)
        }
    }
}

struct StrategyCard: View {
    let strategy: AppSwapStrategy
    let isSelected: Bool
    let badge: String
    let title: String
    let description: String
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isSelected ? Theme.electricEmerald : Theme.elevatedSlate)
                        .foregroundColor(isSelected ? Color(hex: 0x032218) : Theme.textMuted)
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? Theme.electricEmerald : Theme.textMuted)
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(Theme.frostedCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Theme.electricEmerald : Theme.subtleBorder, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
