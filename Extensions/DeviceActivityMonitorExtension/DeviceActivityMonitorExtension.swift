import Foundation
import DeviceActivity
import ManagedSettings
import FamilyControls

/// Background extension that wakes up when DeviceActivity schedules begin or end.
public class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let managedStore = ManagedSettingsStore()
    
    public override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        let storage = AppGroupStorage.shared
        
        // If in reward window, do not shield
        if storage.isRewardWindowActive() {
            return
        }
        
        // Retrieve selected apps from shared container
        if let selection = storage.loadFamilyActivitySelection() {
            managedStore.shield.applications = selection.applicationTokens
            managedStore.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
            managedStore.shield.webDomains = selection.webDomainTokens
        }
    }
    
    public override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // Window ended: lift shields
        managedStore.shield.applications = nil
        managedStore.shield.applicationCategories = nil
        managedStore.shield.webDomains = nil
    }
    
    public override func eventDidReachThreshold(for event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(for: event, activity: activity)
    }
}
