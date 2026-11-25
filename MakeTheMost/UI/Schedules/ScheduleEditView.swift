import SwiftUI

public struct ScheduleListView: View {
    @EnvironmentObject var appState: AppState
    @State private var scheduleToEdit: MakeTheMostSchedule?
    @State private var showActivityPicker: Bool = false
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Shielded Apps Selection Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "app.badge.checkmark")
                                .foregroundColor(Theme.electricEmerald)
                            Text("Target Apps to Shield")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)
                            Spacer()
                            Button("Choose Apps") {
                                showActivityPicker = true
                            }
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.electricEmerald)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.electricEmerald.opacity(0.15))
                            .cornerRadius(8)
                        }
                        
                        Text("Select the distracting apps (Instagram, TikTok, YouTube, etc.) that will trigger your App Swap or Breakout Challenge.")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                    .padding(16)
                    .frostedCardStyle()
                    
                    // List of schedules
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(appState.schedules) { schedule in
                            ScheduleCardView(
                                schedule: schedule,
                                onEdit: {
                                    scheduleToEdit = schedule
                                },
                                onTriggerBreakout: {
                                    appState.activeChallengeToPresent = schedule.challengeCategory
                                    appState.isBreakoutSheetPresented = true
                                }
                            )
                        }
                    }
                }
                .padding(20)
            }
            .background(Theme.deepObsidian.ignoresSafeArea())
            .navigationTitle("Focus Schedules")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        scheduleToEdit = MakeTheMostSchedule(
                            name: "New Focus Window",
                            startTimeMinutes: 9 * 60,
                            endTimeMinutes: 17 * 60
                        )
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Theme.electricEmerald)
                    }
                }
            }
            .sheet(item: $scheduleToEdit) { schedule in
                ScheduleEditView(schedule: schedule) { updated in
                    if let idx = appState.schedules.firstIndex(where: { $0.id == updated.id }) {
                        var list = appState.schedules
                        list[idx] = updated
                        appState.saveSchedules(list)
                    } else {
                        var list = appState.schedules
                        list.append(updated)
                        appState.saveSchedules(list)
                    }
                }
            }
            .sheet(isPresented: $showActivityPicker) {
                FamilyActivityPickerSheet()
            }
        }
    }
}

public struct ScheduleEditView: View {
    @State public var schedule: MakeTheMostSchedule
    public var onSave: (MakeTheMostSchedule) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var startTime: Date
    @State private var endTime: Date
    
    public init(schedule: MakeTheMostSchedule, onSave: @escaping (MakeTheMostSchedule) -> Void) {
        self._schedule = State(initialValue: schedule)
        self.onSave = onSave
        
        let calendar = Calendar.current
        let startComponents = DateComponents(
            hour: schedule.startTimeMinutes / 60,
            minute: schedule.startTimeMinutes % 60
        )
        let endComponents = DateComponents(
            hour: schedule.endTimeMinutes / 60,
            minute: schedule.endTimeMinutes % 60
        )
        self._startTime = State(initialValue: calendar.date(from: startComponents) ?? Date())
        self._endTime = State(initialValue: calendar.date(from: endComponents) ?? Date())
    }
    
    private var isLocked: Bool {
        !ScheduleEvaluator.canEditScheduleSettings(schedule: schedule)
    }
    
    public var body: some View {
        NavigationView {
            Form {
                if isLocked {
                    Section {
                        HStack(spacing: 10) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Theme.crimsonPulse)
                            Text("Schedule is currently active. Settings are locked until the focus window completes.")
                                .font(.caption)
                                .foregroundColor(Theme.crimsonPulse)
                        }
                    }
                }
                
                Section(header: Text("General").foregroundColor(Theme.textMuted)) {
                    TextField("Schedule Name", text: $schedule.name)
                        .disabled(isLocked)
                    
                    Toggle("Enabled", isOn: $schedule.isEnabled)
                        .tint(Theme.electricEmerald)
                        .disabled(isLocked)
                }
                
                Section(header: Text("Time Window").foregroundColor(Theme.textMuted)) {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        .disabled(isLocked)
                        .onChange(of: startTime) { newDate in
                            let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                            schedule.startTimeMinutes = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
                        }
                    
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        .disabled(isLocked)
                        .onChange(of: endTime) { newDate in
                            let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                            schedule.endTimeMinutes = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
                        }
                }
                
                Section(header: Text("Active Days").foregroundColor(Theme.textMuted)) {
                    HStack(spacing: 8) {
                        ForEach(1...7, id: \.self) { day in
                            let isSelected = schedule.activeDaysOfWeek.contains(day)
                            Button(action: {
                                if !isLocked {
                                    if isSelected {
                                        schedule.activeDaysOfWeek.removeAll(where: { $0 == day })
                                    } else {
                                        schedule.activeDaysOfWeek.append(day)
                                    }
                                }
                            }) {
                                Text(dayLetter(day))
                                    .font(.system(size: 13, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                    .background(isSelected ? Theme.electricEmerald : Theme.elevatedSlate)
                                    .foregroundColor(isSelected ? Color(hex: 0x032218) : Theme.textMuted)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                            .disabled(isLocked)
                        }
                    }
                }
                
                Section(header: Text("Breakout Challenge").foregroundColor(Theme.textMuted)) {
                    Picker("Challenge Type", selection: $schedule.challengeCategory) {
                        ForEach(ChallengeCategory.allCases) { cat in
                            Text(cat.displayName).tag(cat)
                        }
                    }
                    .disabled(isLocked)
                    
                    Picker("Difficulty", selection: $schedule.challengeDifficulty) {
                        ForEach(ChallengeDifficulty.allCases) { diff in
                            Text(diff.displayName).tag(diff)
                        }
                    }
                    .disabled(isLocked)
                }
                
                Section(header: Text("App Swap Destination").foregroundColor(Theme.textMuted)) {
                    TextField("Swap App Name", text: $schedule.swapAppLabel)
                        .disabled(isLocked)
                    TextField("Swap URL Scheme", text: $schedule.swapAppUrl)
                        .disabled(isLocked)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.deepObsidian.ignoresSafeArea())
            .navigationTitle("Edit Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(schedule)
                        dismiss()
                    }
                    .foregroundColor(Theme.electricEmerald)
                    .disabled(isLocked)
                }
            }
        }
    }
    
    private func dayLetter(_ day: Int) -> String {
        switch day {
        case 1: return "S"
        case 2: return "M"
        case 3: return "T"
        case 4: return "W"
        case 5: return "T"
        case 6: return "F"
        case 7: return "S"
        default: return ""
        }
    }
}
