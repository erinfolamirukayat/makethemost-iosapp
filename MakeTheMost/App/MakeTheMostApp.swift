import SwiftUI

@main
struct MakeTheMostApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    
    init() {
        // Dark navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.06, alpha: 1.0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(red: 0.07, green: 0.08, blue: 0.12, alpha: 1.0)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(screenTimeManager)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    appState.handleOpenURL(url)
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var body: some View {
        TabView(selection: $appState.activeTab) {
            DashboardView()
                .tabItem {
                    Label("Focus", systemImage: "timer")
                }
                .tag(0)
            
            ScheduleListView()
                .tabItem {
                    Label("Schedules", systemImage: "calendar.badge.clock")
                }
                .tag(1)
            
            AppSwapSettingsView()
                .tabItem {
                    Label("App Swap", systemImage: "arrow.triangle.swap")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle")
                }
                .tag(3)
        }
        .accentColor(Theme.electricEmerald)
        .sheet(isPresented: $appState.isBreakoutSheetPresented) {
            if let category = appState.activeChallengeToPresent {
                BreakoutChallengeHostView(
                    category: category,
                    difficulty: appState.schedules.first?.challengeDifficulty ?? .easy
                )
            }
        }
        .sheet(isPresented: $appState.isRewardCelebrationPresented) {
            ChallengeSuccessView()
        }
        .sheet(isPresented: $appState.showShortcutsGuideSheet) {
            ShortcutsSetupGuideView()
        }
        .task {
            screenTimeManager.checkAuthorizationStatus()
            screenTimeManager.evaluateAndApplyShields()
        }
    }
}
