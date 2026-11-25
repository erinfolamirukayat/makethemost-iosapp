import Foundation
import AppIntents

/// Exposes MakeTheMost AppIntents to the Apple Shortcuts library.
public struct MakeTheMostShortcutsProvider: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PerformAppSwapIntent(),
            phrases: [
                "Swap \(.applicationName) distractions",
                "Run \(.applicationName) swap",
                "Make the most of my time with \(.applicationName)"
            ],
            shortTitle: "App Swap",
            systemImageName: "arrow.triangle.swap"
        )
    }
}
