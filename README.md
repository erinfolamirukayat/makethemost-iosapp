# MakeTheMost — Native iOS (SwiftUI & Screen Time)

Native iOS implementation of **MakeTheMost**, matching the production Android app and sharing the Neon Serverless Postgres + Vercel backend (`https://makethemost-backend.vercel.app`).

---

## 🏗 Multi-Target Architecture

Apple's Screen Time framework requires isolated extension targets to safely manage app shielding, activity monitoring, and shield button interactions. The project is structured across 4 targets with a shared App Group container:

```
ios/
├── MakeTheMost.xcodeproj/              # Xcode project with 4 configured targets
├── MakeTheMost/                        # Target 1: Main SwiftUI Application
│   ├── App/                            # Lifecycle, AppState, deep linking (makethemost://)
│   ├── Core/
│   │   ├── Models/                     # Data models, UserAccount, 30-day trial math
│   │   ├── Storage/                    # AppGroupStorage (group.com.makethemost.app)
│   │   ├── Network/                    # NeonAPIClient (Vercel Serverless + Neon DB)
│   │   ├── ScreenTime/                 # ScreenTimeManager (FamilyControls + ManagedSettings)
│   │   ├── Motion/                     # SquatMotionDetector (CoreMotion 50Hz sensor fusion)
│   │   └── Intents/                    # AppSwapIntent & ShortcutsProvider
│   ├── Domain/                         # ChallengeEngine, Scripture & Quote Libraries, ScheduleEvaluator
│   ├── UI/
│   │   ├── Theme/                      # High-contrast Dark Obsidian/Emerald/Amber design system
│   │   ├── Dashboard/                  # Main focus dashboard, status banners, 15-min countdown
│   │   ├── Schedules/                  # Schedule editor, time windows, FamilyActivityPicker
│   │   ├── Challenges/                 # Squats, Scripture Typing, Wisdom Quotes, Math
│   │   ├── AppSwap/                    # App Swap strategy toggle & Shortcuts guide
│   │   ├── Account/                    # Auth, Neon sync, 30-day trial badge, feedback, deletion
│   │   └── Onboarding/                 # Value proposition & FamilyControls authorization
│   └── Resources/                      # Info.plist & MakeTheMost.entitlements
├── Extensions/
│   ├── DeviceActivityMonitorExtension/ # Target 2: Background schedule interval observer
│   ├── ShieldConfigurationExtension/   # Target 3: Customizes system shield UI & dynamic scripture
│   └── ShieldActionExtension/          # Target 4: Intercepts 1-tap swap & breakout clicks
└── Shared/                             # Shared constants, App Group keys, shield config
```

---

## 🛡 App Swap Strategy (Hybrid Approach)

1. **Default Mode (Zero External Setup)**:
   - When a user launches a distracting app (e.g., Instagram, TikTok), Apple's Screen Time shield appears.
   - The shield presents dynamic NKJV Scripture or Wisdom Quotes, a primary 1-tap **"Open Bible App"** button (`youversion://`), and a secondary **"Breakout Challenge"** button.
   - Configured via `ShieldConfigurationExtension` and `ShieldActionExtension`.

2. **Power-User Mode (Zero-Click Instant Swap)**:
   - Integrates with Apple Shortcuts Personal Automations via Swift `AppIntent` (`PerformAppSwapIntent`).
   - Trigger: *"When [Instagram, TikTok, ...] is opened"* -> Action: *"Perform MakeTheMost App Swap"*.
   - If an intentional schedule is active and the user is **not** in their 15-minute reward window, iOS immediately routes directly to the Bible App with **0 taps required**.
   - If the user is inside their 15-minute reward window, the distracting app opens uninterrupted.

---

## ⚡ Breakout Challenges (V1 Scope)

- **Physical Squats**:
  - Utilizes 50Hz `CoreMotion` sensor fusion (`CMMotionManager.startDeviceMotionUpdates`).
  - Calibrated gravity projection: isolates vertical linear acceleration regardless of device tilt or pocket orientation.
  - State Machine: `READY` -> descent ($\le -1.8\,\text{m/s}^2$) -> `DESCENDING` -> bottom upward drive ($\ge +1.8\,\text{m/s}^2$) -> `ASCENDING` -> top zero-settle ($[-1.2, +1.2]\,\text{m/s}^2$) -> `COMPLETED` + 700ms bounce cooldown.
- **Faith & Scripture Typing**:
  - 100 hand-curated New King James Version (NKJV) Bible passages categorized by difficulty.
  - Character-by-character real-time accuracy checking.
  - Anti-cheat paste detection (> 2 characters inserted simultaneously blocks progress).
- **Productivity & Wisdom Quotes**:
  - Curated discipline and focus reflections from Marcus Aurelius, Seneca, Epictetus, Cal Newport, James Clear, etc.
- **Cognitive Mental Math**:
  - Arithmetic problem gauntlet with a strict streak counter; one incorrect answer resets the streak to 0.
- **15-Minute Unshield Reward Window**:
  - Conquering any breakout challenge immediately grants a 15-minute de-shield window.
  - Live countdown ticker in the app and auto-restoring shields upon expiration.

---

## ☁️ Shared Neon Backend Integration

Direct integration with `https://makethemost-backend.vercel.app`:
- `POST /api/users/login`: Authenticates with SHA-256 password hash.
- `POST /api/users/sync`: Profile registration and multi-device sync.
- `POST /api/users/sync-schedules`: Cloud backup of intentional schedules.
- `POST /api/compliance/sync`: Syncs daily intentional focus minutes and bypasses.
- `POST /api/users/delete-account`: Permanent cloud data deletion (App Store requirement).
- `POST /api/feedback`: Direct in-app feedback portal.
- **Free Community Edition**: All Breakout Challenges, App Swap modes, and cloud backup are 100% free with no trial limits.

---

## 🚀 Getting Started in Xcode

1. Open `ios/MakeTheMost.xcodeproj` in **Xcode 14.3+** (macOS).
2. Set your **Apple Developer Team** under Target Signing for all 4 targets:
   - `MakeTheMost`
   - `DeviceActivityMonitorExtension`
   - `ShieldConfigurationExtension`
   - `ShieldActionExtension`
3. Ensure the App Group identifier is set to `group.com.makethemost.app` (or your team's prefixed group).
## 📱 Testing in Xcode: Simulator vs. Physical Device

### 1. Running on the Xcode Simulator
Yes! Xcode includes the **iOS Simulator** (Apple's software emulator). You can select any device (e.g., iPhone 15 Pro, iPhone 16) from the device target dropdown in Xcode and press `Cmd + R` to run immediately.

**What works 100% in the Simulator:**
- **Full SwiftUI UI & Navigation**: Dashboard, Focus schedules, App Swap configuration, Account, Onboarding.
- **Breakout Challenges**:
  - **Scripture Typing**: Live typing, character-by-character accuracy, anti-paste burst detection.
  - **Wisdom Quotes**: Reflection and quote typing.
  - **Mental Math**: Dynamic arithmetic problems, answer validation, streak tracker.
  - **Squats Challenge**: The view includes an in-app `Simulate 1 Rep (Testing)` debug button so you can test and conquer the squat challenge in the Simulator without physical sensors.
- **15-Minute Reward Window**: Countdown ticker, celebration modal, and timer state management.
- **Neon Cloud Sync**: Live communication with `https://makethemost-backend.vercel.app`.
- **Apple Shortcuts**: You can open the Simulator's built-in Shortcuts app to test AppIntents.

### 2. Apple Screen Time Hardware Limitation
Apple imposes a platform restriction on `FamilyControls` and `ManagedSettings`:
- Real system shields that lock physical apps (Instagram, TikTok) only run on a **physical iPhone** signed into an Apple ID with Family Controls permission enabled.
- On the Simulator, `FamilyActivityPicker` and `AuthorizationCenter` run in mock/development mode. For production shield validation, connect a physical device via USB or WiFi.
