import SwiftUI

public struct ScheduleCardView: View {
    public let schedule: MakeTheMostSchedule
    public var onEdit: () -> Void
    public var onTriggerBreakout: () -> Void
    
    private var isCurrentlyActive: Bool {
        ScheduleEvaluator.isScheduleCurrentlyActive(schedule: schedule)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(schedule.name)
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("\(formattedTime(minutes: schedule.startTimeMinutes)) – \(formattedTime(minutes: schedule.endTimeMinutes))")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                // Active Badge
                if isCurrentlyActive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Theme.electricEmerald)
                            .frame(width: 8, height: 8)
                        Text("ACTIVE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.electricEmerald)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.electricEmerald.opacity(0.15))
                    .cornerRadius(6)
                }
            }
            
            // Days of Week
            HStack(spacing: 6) {
                ForEach(1...7, id: \.self) { day in
                    let isSelected = schedule.activeDaysOfWeek.contains(day)
                    Text(dayLetter(day))
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 26, height: 26)
                        .background(isSelected ? Theme.electricEmerald : Theme.elevatedSlate)
                        .foregroundColor(isSelected ? Color(hex: 0x032218) : Theme.textMuted)
                        .cornerRadius(6)
                }
            }
            
            Divider()
                .background(Theme.subtleBorder)
            
            // Challenge & Swap App Info
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: schedule.challengeCategory.sfSymbol)
                        .foregroundColor(Theme.warmAmber)
                    Text(schedule.challengeCategory.displayName)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                Text(schedule.challengeDifficulty.displayName)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.elevatedSlate)
                    .foregroundColor(Theme.warmAmber)
                    .cornerRadius(4)
            }
            
            // Action Buttons
            HStack(spacing: 10) {
                Button(action: onTriggerBreakout) {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                        Text("Breakout Challenge")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.warmAmber)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Theme.warmAmber.opacity(0.15))
                    .cornerRadius(8)
                }
                
                Button(action: onEdit) {
                    Text("Edit")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Theme.elevatedSlate)
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .frostedCardStyle()
    }
    
    private func formattedTime(minutes: Int) -> String {
        let hour = minutes / 60
        let min = minutes % 60
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", displayHour, min, period)
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
