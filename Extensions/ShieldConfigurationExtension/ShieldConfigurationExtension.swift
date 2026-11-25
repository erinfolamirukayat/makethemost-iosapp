import UIKit
import ManagedSettings
import ManagedSettingsUI

/// Customizes the system Screen Time shield with dynamic Scripture passages,
/// intentionality prompts, and 1-tap App Swap / Breakout Challenge action buttons.
public class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    private func buildConfiguration() -> ShieldConfiguration {
        let storage = AppGroupStorage.shared
        let config = storage.loadShieldConfig()
        
        let scriptureBody = "\"\(config.scriptureText)\"\n— \(config.scriptureReference)"
        
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: UIColor(red: 0.04, green: 0.04, blue: 0.06, alpha: 0.98), // Deep Obsidian #090A0F
            icon: UIImage(systemName: "shield.lefthalf.filled"),
            title: ShieldConfiguration.Label(
                text: config.title,
                color: UIColor.white
            ),
            subtitle: ShieldConfiguration.Label(
                text: scriptureBody,
                color: UIColor(red: 0.80, green: 0.84, blue: 0.88, alpha: 1.0) // Slate-200
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: config.swapAppButtonTitle,
                color: UIColor(red: 0.01, green: 0.13, blue: 0.09, alpha: 1.0) // Deep dark emerald text
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.06, green: 0.73, blue: 0.51, alpha: 1.0), // Emerald #10B981
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: config.challengeButtonTitle,
                color: UIColor(red: 0.96, green: 0.62, blue: 0.04, alpha: 1.0) // Amber #F59E0B
            )
        )
    }
    
    public override func configuration(shielding application: Application) -> ShieldConfiguration {
        buildConfiguration()
    }
    
    public override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        buildConfiguration()
    }
    
    public override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        buildConfiguration()
    }
    
    public override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        buildConfiguration()
    }
}
