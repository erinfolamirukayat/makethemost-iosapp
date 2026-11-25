import Foundation

public struct InterceptionDecision: Equatable {
    public let shouldShield: Bool
    public let matchedSchedule: MakeTheMostSchedule?
    public let inRewardWindow: Bool
    public let remainingRewardSeconds: Int
    
    public init(
        shouldShield: Bool,
        matchedSchedule: MakeTheMostSchedule? = nil,
        inRewardWindow: Bool = false,
        remainingRewardSeconds: Int = 0
    ) {
        self.shouldShield = shouldShield
        self.matchedSchedule = matchedSchedule
        self.inRewardWindow = inRewardWindow
        self.remainingRewardSeconds = remainingRewardSeconds
    }
}

public enum ScheduleEvaluator {
    
    /// Evaluates if a given schedule is currently active at this moment.
    /// Supports both same-day windows (e.g., 09:00 to 17:00) and overnight windows (e.g., 22:00 to 06:00).
    public static func isScheduleCurrentlyActive(
        schedule: MakeTheMostSchedule,
        now: Date = Date()
    ) -> Bool {
        guard schedule.isEnabled else { return false }
        
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: now) // 1 = Sunday ... 7 = Saturday
        guard schedule.activeDaysOfWeek.contains(dayOfWeek) else { return false }
        
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentMinutesFromMidnight = hour * 60 + minute
        
        if schedule.startTimeMinutes <= schedule.endTimeMinutes {
            // Same day window (e.g., 09:00 -> 17:00)
            return currentMinutesFromMidnight >= schedule.startTimeMinutes &&
                   currentMinutesFromMidnight < schedule.endTimeMinutes
        } else {
            // Overnight window (e.g., 22:00 -> 06:00)
            return currentMinutesFromMidnight >= schedule.startTimeMinutes ||
                   currentMinutesFromMidnight < schedule.endTimeMinutes
        }
    }
    
    /// Enforces the intentionality rule:
    /// Once the scheduled window sets in, settings and rules cannot be edited until the window ends.
    public static func canEditScheduleSettings(
        schedule: MakeTheMostSchedule,
        now: Date = Date()
    ) -> Bool {
        !isScheduleCurrentlyActive(schedule: schedule, now: now)
    }
    
    /// Evaluates overall interception status across all active schedules,
    /// taking into account the 15-minute reward unshield window.
    public static func evaluateCurrentInterception(
        schedules: [MakeTheMostSchedule],
        now: Date = Date()
    ) -> InterceptionDecision {
        let storage = AppGroupStorage.shared
        let isRewarded = storage.isRewardWindowActive()
        let remainingSeconds = storage.remainingRewardSeconds()
        
        if isRewarded {
            return InterceptionDecision(
                shouldShield: false,
                matchedSchedule: nil,
                inRewardWindow: true,
                remainingRewardSeconds: remainingSeconds
            )
        }
        
        for schedule in schedules {
            if isScheduleCurrentlyActive(schedule: schedule, now: now) {
                return InterceptionDecision(
                    shouldShield: true,
                    matchedSchedule: schedule,
                    inRewardWindow: false,
                    remainingRewardSeconds: 0
                )
            }
        }
        
        return InterceptionDecision(shouldShield: false)
    }
}
