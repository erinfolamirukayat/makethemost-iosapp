import Foundation
import CoreMotion
import Combine

public enum SquatPhase: String {
    case ready = "READY"
    case descending = "DESCENDING"
    case ascending = "ASCENDING"
    case completed = "COMPLETED"
    
    public var instructionText: String {
        switch self {
        case .ready: return "Stand tall and begin squat"
        case .descending: return "Lower your hips down"
        case .ascending: return "Drive up through your heels"
        case .completed: return "Rep counted!"
        }
    }
}

/// Real-time 50Hz CoreMotion sensor fusion squat repetition detector.
/// Uses Earth-gravity orientation projection to accurately detect vertical squat repetitions
/// regardless of device tilt or pocket orientation.
public final class SquatMotionDetector: ObservableObject {
    @Published public private(set) var repCount: Int = 0
    @Published public private(set) var targetReps: Int = 15
    @Published public private(set) var currentPhase: SquatPhase = .ready
    @Published public private(set) var currentVerticalAcceleration: Double = 0.0
    @Published public private(set) var isDetecting: Bool = false
    @Published public private(set) var isCompleted: Bool = false
    
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    private var lastPhaseChangeTime: Date = Date()
    private var lastRepTime: Date = Date.distantPast
    
    public var onRepCounted: ((Int) -> Void)?
    public var onChallengeCompleted: (() -> Void)?
    
    public init(targetReps: Int = 15) {
        self.targetReps = targetReps
        self.queue.qualityOfService = .userInteractive
        self.queue.maxConcurrentOperationCount = 1
    }
    
    public func start(targetReps: Int = 15) {
        guard motionManager.isDeviceMotionAvailable else {
            print("SquatMotionDetector: Device motion not available (e.g. Simulator).")
            return
        }
        
        self.targetReps = targetReps
        self.repCount = 0
        self.isCompleted = false
        self.currentPhase = .ready
        self.lastPhaseChangeTime = Date()
        self.lastRepTime = Date.distantPast
        self.isDetecting = true
        
        // 50Hz update rate (0.02s interval)
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0
        
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: queue) { [weak self] motion, error in
            guard let self = self, let motion = motion, error == nil else { return }
            self.processDeviceMotion(motion)
        }
    }
    
    public func stop() {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
        DispatchQueue.main.async {
            self.isDetecting = false
        }
    }
    
    public func reset() {
        stop()
        DispatchQueue.main.async {
            self.repCount = 0
            self.isCompleted = false
            self.currentPhase = .ready
            self.currentVerticalAcceleration = 0.0
        }
    }
    
    /// Simulates a repetition (useful for previews and testing)
    public func simulateRepetition() {
        DispatchQueue.main.async {
            self.repCount += 1
            self.onRepCounted?(self.repCount)
            if self.repCount >= self.targetReps && !self.isCompleted {
                self.isCompleted = true
                self.stop()
                self.onChallengeCompleted?()
            }
        }
    }
    
    private func processDeviceMotion(_ motion: CMDeviceMotion) {
        let gx = motion.gravity.x
        let gy = motion.gravity.y
        let gz = motion.gravity.z
        
        let gMag = sqrt(gx * gx + gy * gy + gz * gz)
        guard gMag > 1e-3 else { return }
        
        // Unit gravity vector pointing downward relative to the device
        let unitGx = gx / gMag
        let unitGy = gy / gMag
        let unitGz = gz / gMag
        
        // User acceleration in g's (excluding 1g gravity)
        let ux = motion.userAcceleration.x
        let uy = motion.userAcceleration.y
        let uz = motion.userAcceleration.z
        
        // Total dot product gives user acceleration projected onto Earth's vertical axis
        // In CoreMotion, userAcceleration along gravity is positive when accelerating in the direction of gravity.
        // Convert from g to m/s^2 (1g = 9.80665 m/s^2).
        // Negative = downward acceleration (dropping into squat).
        // Positive = upward acceleration/braking (driving up out of squat).
        let verticalLinearMps2 = -(ux * unitGx + uy * unitGy + uz * unitGz) * 9.80665
        
        let now = Date()
        let cooldownSeconds: TimeInterval = 0.7 // 700ms cooldown between reps
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentVerticalAcceleration = verticalLinearMps2
            
            // Rep cooldown check
            if now.timeIntervalSince(self.lastRepTime) < cooldownSeconds {
                self.currentPhase = .ready
                return
            }
            
            switch self.currentPhase {
            case .ready:
                // User starts dropping into squat (downward acceleration)
                if verticalLinearMps2 <= -1.8 {
                    self.currentPhase = .descending
                    self.lastPhaseChangeTime = now
                }
                
            case .descending:
                // Timeout if descent takes longer than 3.5s
                if now.timeIntervalSince(self.lastPhaseChangeTime) > 3.5 {
                    self.currentPhase = .ready
                } else if verticalLinearMps2 >= 1.8 {
                    // Upward reversal: user reaches depth and drives upward
                    self.currentPhase = .ascending
                    self.lastPhaseChangeTime = now
                }
                
            case .ascending:
                // Timeout if ascent takes longer than 3.5s
                if now.timeIntervalSince(self.lastPhaseChangeTime) > 3.5 {
                    self.currentPhase = .ready
                } else if verticalLinearMps2 >= -1.2 && verticalLinearMps2 <= 1.2 {
                    // Settled back to near-zero at top of squat
                    self.currentPhase = .completed
                    self.lastRepTime = now
                    self.repCount += 1
                    self.onRepCounted?(self.repCount)
                    
                    if self.repCount >= self.targetReps {
                        self.isCompleted = true
                        self.stop()
                        self.onChallengeCompleted?()
                    } else {
                        self.currentPhase = .ready
                    }
                }
                
            case .completed:
                self.currentPhase = .ready
            }
        }
    }
}
