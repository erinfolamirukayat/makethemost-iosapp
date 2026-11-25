import SwiftUI

public struct ShortcutsSetupGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Zero-Click Instant Redirection")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        
                        Text("Follow these 3 quick steps in Apple's Shortcuts app to redirect distracting apps immediately without even tapping a button.")
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    // Step 1
                    StepCard(
                        number: "1",
                        title: "Open Shortcuts & Create Personal Automation",
                        description: "Open the iOS Shortcuts app, tap the 'Automation' tab at the bottom, and tap the '+' or 'Create Personal Automation' button."
                    )
                    
                    // Step 2
                    StepCard(
                        number: "2",
                        title: "Choose 'App' Trigger",
                        description: "Scroll down and select 'App'. Choose your distracting apps (e.g., Instagram, TikTok, YouTube). Select 'Is Opened' and check 'Run Immediately' (without asking)."
                    )
                    
                    // Step 3
                    StepCard(
                        number: "3",
                        title: "Add Action: 'Perform MakeTheMost App Swap'",
                        description: "Search for 'MakeTheMost' in the action search bar and choose 'Perform MakeTheMost App Swap'. Tap Done. Whenever you open those apps during focus hours, MakeTheMost instantly routes you straight to the Bible App!"
                    )
                    
                    Spacer(minLength: 16)
                    
                    // Open Shortcuts Button
                    Button(action: openShortcutsApp) {
                        HStack {
                            Image(systemName: "square.stack.3d.up.fill")
                            Text("Open Apple Shortcuts App")
                        }
                        .primaryButtonStyle()
                    }
                }
                .padding(20)
            }
            .background(Theme.deepObsidian.ignoresSafeArea())
            .navigationTitle("Power-User Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.electricEmerald)
                }
            }
        }
    }
    
    private func openShortcutsApp() {
        if let url = URL(string: "shortcuts://") {
            UIApplication.shared.open(url)
        }
    }
}

struct StepCard: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.electricEmerald)
                    .frame(width: 32, height: 32)
                Text(number)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: 0x032218))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frostedCardStyle()
    }
}
