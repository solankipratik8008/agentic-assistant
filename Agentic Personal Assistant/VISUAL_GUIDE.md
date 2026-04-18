# 🎯 VISUAL QUICK START GUIDE

```
╔══════════════════════════════════════════════════════════════════════╗
║                  AGENTIC PERSONAL ASSISTANT                          ║
║                     Setup in 5 Minutes                               ║
╚══════════════════════════════════════════════════════════════════════╝

┌────────────────────────────────────────────────────────────────────┐
│ STEP 1: GET API KEYS (Required)                                    │
└────────────────────────────────────────────────────────────────────┘

   🔑 Claude API Key
   ┌─────────────────────────────────────────────────────────────┐
   │ 1. Visit: https://console.anthropic.com/                    │
   │ 2. Sign up / Log in                                         │
   │ 3. Click "Create Key"                                       │
   │ 4. Copy the key → looks like: sk-ant-api03-xxxxx           │
   └─────────────────────────────────────────────────────────────┘

   🌤️ Weather API Key
   ┌─────────────────────────────────────────────────────────────┐
   │ 1. Visit: https://openweathermap.org/api                   │
   │ 2. Sign up (FREE!)                                          │
   │ 3. Verify email                                             │
   │ 4. Copy API key from dashboard                             │
   │ 5. Wait 10 minutes for activation                          │
   └─────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│ STEP 2: ADD KEYS TO PROJECT                                        │
└────────────────────────────────────────────────────────────────────┘

   📁 Open File: Services/Configuration.swift
   
   ┌─────────────────────────────────────────────────────────────┐
   │ struct Configuration {                                      │
   │                                                              │
   │     // PASTE YOUR KEYS HERE ↓                              │
   │     static let claudeAPIKey = "sk-ant-api03-YOUR-KEY"      │
   │     static let weatherAPIKey = "YOUR-WEATHER-KEY"          │
   │                                                              │
   │ }                                                            │
   └─────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│ STEP 3: ADD INFO.PLIST PERMISSION                                  │
└────────────────────────────────────────────────────────────────────┘

   📋 In Xcode:
   
   1. Click "Agentic Personal Assistant" (top of Navigator)
   2. Select "Agentic Personal Assistant" target
   3. Click "Info" tab
   4. Click "+" button
   5. Add this entry:
   
   ┌─────────────────────────────────────────────────────────────┐
   │ Key:   NSLocationWhenInUseUsageDescription                  │
   │ Value: We need your location to provide weather             │
   │        information and find nearby places.                  │
   └─────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│ STEP 4: BUILD & RUN                                                │
└────────────────────────────────────────────────────────────────────┘

   ⌨️ Keyboard Shortcuts:
   
   Cmd + B  → Build the project
   Cmd + R  → Run on simulator
   
   Or use Xcode buttons:
   ▶️ Play button in top toolbar

┌────────────────────────────────────────────────────────────────────┐
│ STEP 5: TEST FEATURES                                              │
└────────────────────────────────────────────────────────────────────┘

   Try these commands in order:

   1️⃣ General Chat
   ┌─────────────────────────────────────────────────────────────┐
   │ You:  Hello!                                                │
   │ AI:   Hi! How can I help you today? 👋                     │
   └─────────────────────────────────────────────────────────────┘

   2️⃣ Weather
   ┌─────────────────────────────────────────────────────────────┐
   │ You:  What's the weather in London?                         │
   │ AI:   📍 London                                             │
   │       🌡️ Temperature: 15.0°C                               │
   │       ☁️ Condition: Clouds - Overcast                      │
   └─────────────────────────────────────────────────────────────┘

   3️⃣ Reminder
   ┌─────────────────────────────────────────────────────────────┐
   │ You:  Remind me to study at 6 PM                            │
   │ AI:   ✅ Reminder set! I'll notify you to "study"          │
   │       on Apr 17, 2026 at 6:00 PM.                          │
   └─────────────────────────────────────────────────────────────┘
   
   → App will ask for notification permission
   → Tap "Allow"

   4️⃣ Navigation
   ┌─────────────────────────────────────────────────────────────┐
   │ You:  Find parking near me                                  │
   │ AI:   🗺️ Opening map to search for: parking               │
   └─────────────────────────────────────────────────────────────┘
   
   → App will ask for location permission
   → Tap "Allow While Using App"
   → Map sheet opens with results

╔══════════════════════════════════════════════════════════════════════╗
║                         PROJECT FILES                                ║
╚══════════════════════════════════════════════════════════════════════╝

📂 Project Structure:

Agentic Personal Assistant/
├── 📱 Agentic_Personal_AssistantApp.swift    ← App entry
├── 🖥️ ContentView.swift                      ← Main UI
│
├── 📊 Models/
│   ├── Message.swift                         ← Chat + API models
│   ├── UserIntent.swift                      ← Intent types
│   └── WeatherData.swift                     ← Weather models
│
├── 🔧 Services/
│   ├── ClaudeAPIService.swift                ← AI integration
│   ├── WeatherService.swift                  ← Weather API
│   ├── LocationService.swift                 ← GPS
│   ├── NotificationService.swift             ← Reminders
│   ├── IntentDetectionService.swift          ← NLP
│   └── Configuration.swift                   ← ⚠️ ADD KEYS HERE
│
├── 🧠 ViewModels/
│   └── ChatViewModel.swift                   ← Business logic
│
└── 🎨 Views/Components/
    ├── ChatBubbleView.swift                  ← Message bubbles
    ├── MessageInputView.swift                ← Text input
    ├── TypingIndicatorView.swift             ← Animated dots
    └── MapSearchView.swift                   ← Map interface

╔══════════════════════════════════════════════════════════════════════╗
║                      COMMON QUESTIONS                                ║
╚══════════════════════════════════════════════════════════════════════╝

❓ Where do I add API keys?
   → Services/Configuration.swift

❓ Do I need to pay for APIs?
   → Weather: FREE tier (1000 calls/day)
   → Claude: Paid, but affordable (~$3/million tokens)

❓ Why isn't location working?
   → Check Info.plist has location permission key
   → Grant permission when app asks
   → Try on real device (simulator can be flaky)

❓ Weather API not working?
   → Wait 10 minutes after signup
   → Check you copied the full API key
   → Try: "weather in London" (specific city)

❓ AI not responding?
   → Check internet connection
   → Verify Claude API key is correct
   → Look for error alert in app

❓ Build errors?
   → Clean: Cmd+Shift+K
   → Build: Cmd+B
   → Check all files are in project

╔══════════════════════════════════════════════════════════════════════╗
║                     KEYBOARD SHORTCUTS                               ║
╚══════════════════════════════════════════════════════════════════════╝

Cmd + B          Build project
Cmd + R          Run app
Cmd + .          Stop running
Cmd + Shift + K  Clean build folder
Cmd + Shift + Y  Show/hide console
Cmd + U          Run tests
Cmd + 0          Show/hide Navigator
Cmd + Option + 0 Show/hide Inspector

╔══════════════════════════════════════════════════════════════════════╗
║                        NEXT STEPS                                    ║
╚══════════════════════════════════════════════════════════════════════╝

After testing basic features:

1. 📖 Read README.md for detailed info
2. 🏗️ Check ARCHITECTURE.md to understand design
3. 🐛 Use TROUBLESHOOTING.md if stuck
4. 🧪 Run tests: Cmd+U
5. 🎨 Customize UI colors/design
6. 🚀 Add your own features

╔══════════════════════════════════════════════════════════════════════╗
║                       DOCUMENTATION                                  ║
╚══════════════════════════════════════════════════════════════════════╝

📚 All guides included:

✓ README.md              - Complete setup & overview
✓ QUICK_START_GUIDE.swift - Fast reference
✓ ARCHITECTURE.md        - System design diagrams
✓ FEATURES.md           - Feature list & roadmap
✓ TROUBLESHOOTING.md    - Debug guide
✓ APIKeySetup.swift     - Detailed API instructions
✓ PROJECT_SUMMARY.md    - What we built

╔══════════════════════════════════════════════════════════════════════╗
║                      VERIFICATION                                    ║
╚══════════════════════════════════════════════════════════════════════╝

✅ Checklist before building:

[ ] Claude API key added to Configuration.swift
[ ] Weather API key added to Configuration.swift
[ ] Info.plist has NSLocationWhenInUseUsageDescription
[ ] Project builds without errors (Cmd+B)
[ ] Simulator/device selected in Xcode
[ ] Internet connection available

╔══════════════════════════════════════════════════════════════════════╗
║                        SUCCESS!                                      ║
╚══════════════════════════════════════════════════════════════════════╝

You now have a production-ready iOS app with:

✨ AI-powered chat interface
✨ Weather integration
✨ Smart reminders
✨ Map navigation
✨ Clean MVVM architecture
✨ Comprehensive documentation

         🎉 Happy Coding! 🎉

```
