import SwiftUI
import FamilyControls

public struct FamilyActivityPickerSheet: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationView {
            FamilyActivityPicker(
                headerText: "Select Distracting Apps to Intercept & Shield",
                selection: $screenTimeManager.activitySelection
            )
            .navigationTitle("Shielded Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        screenTimeManager.updateSelection(screenTimeManager.activitySelection)
                        dismiss()
                    }
                    .foregroundColor(Theme.electricEmerald)
                }
            }
        }
    }
}
