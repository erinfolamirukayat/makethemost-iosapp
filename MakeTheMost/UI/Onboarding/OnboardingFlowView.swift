import SwiftUI
import FamilyControls

public struct OnboardingFlowView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: Int = 0
    
    public var body: some View {
        VStack {
            TabView(selection: $currentStep) {
                // Step 0: Welcome & Philosophy
                OnboardingStepView(
                    iconName: "hourglass.circle.fill",
                    iconColor: Theme.electricEmerald,
                    title: "Make The Most of Every Hour",
                    subtitle: "“Look carefully then how you walk, not as unwise but as wise, making the best use of the time.” — Ephesians 5:15-16",
                    description: "MakeTheMost intercepts mindless digital scrolling and redirects your attention toward uplifting habits and spiritual depth."
                )
                .tag(0)
                
                // Step 1: App Swap
                OnboardingStepView(
                    iconName: "arrow.triangle.swap",
                    iconColor: Theme.electricEmerald,
                    title: "Our Signature App Swap",
                    subtitle: "Turn Distraction Into Intention",
                    description: "Whenever you open Instagram, TikTok, or other distracting apps, MakeTheMost presents Scripture and offers a 1-tap swap straight to the Bible App."
                )
                .tag(1)
                
                // Step 2: Breakout Challenges
                OnboardingStepView(
                    iconName: "figure.run.square.stack.fill",
                    iconColor: Theme.warmAmber,
                    title: "Breakout Challenges",
                    subtitle: "Real Friction to Break the Trance",
                    description: "Need to unlock a distracting app? Earn a 15-minute reward window by completing Squats (CoreMotion sensor fusion), Scripture Typing, Wisdom Reflections, or Mental Math."
                )
                .tag(2)
                
                // Step 3: Screen Time Authorization
                ScreenTimeAuthStepView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
            // Bottom Action
            HStack {
                if currentStep < 3 {
                    Button("Skip") {
                        dismiss()
                    }
                    .foregroundColor(Theme.textMuted)
                    
                    Spacer()
                    
                    Button("Next") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .font(.headline)
                    .foregroundColor(Theme.electricEmerald)
                } else {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Get Started")
                            .primaryButtonStyle()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Theme.deepObsidian.ignoresSafeArea())
    }
}

struct OnboardingStepView: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let description: String
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Image(systemName: iconName)
                    .font(.system(size: 60))
                    .foregroundColor(iconColor)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Theme.warmAmber)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Text(description)
                .font(.body)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

struct ScreenTimeAuthStepView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Theme.electricEmerald.opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.electricEmerald)
            }
            
            VStack(spacing: 8) {
                Text("Enable Screen Time Shield")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                
                Text("Apple's Official Shield Framework")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
            
            Text("To intercept chosen apps and display intentionality prompts, Apple requires FamilyControls permission.")
                .font(.body)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: {
                Task {
                    await screenTimeManager.requestAuthorization()
                }
            }) {
                HStack {
                    Image(systemName: screenTimeManager.isAuthorized ? "checkmark.circle.fill" : "lock.open.fill")
                    Text(screenTimeManager.isAuthorized ? "Permission Granted" : "Authorize Screen Time")
                }
                .font(.headline)
                .foregroundColor(screenTimeManager.isAuthorized ? Theme.textPrimary : Color(hex: 0x032218))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(screenTimeManager.isAuthorized ? Theme.elevatedSlate : Theme.electricEmerald)
                .cornerRadius(12)
                .padding(.horizontal, 32)
            }
            .disabled(screenTimeManager.isAuthorized)
            
            Spacer()
        }
    }
}
