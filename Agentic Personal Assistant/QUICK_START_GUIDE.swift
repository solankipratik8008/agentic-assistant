//
//  QUICK_START_GUIDE.swift
//  Agentic Personal Assistant
//
//  Step-by-step guide to get started
//

/*

🎯 QUICK START GUIDE
====================

STEP 1: ADD API KEYS
--------------------
1. Open: Services/Configuration.swift
2. Add your Claude API key (get it from: https://console.anthropic.com/)
3. Add your Weather API key (get it from: https://openweathermap.org/api)

Example:
```swift
static let claudeAPIKey = "sk-ant-api03-xxxxx"
static let weatherAPIKey = "abc123xxxxx"
```

STEP 2: CONFIGURE INFO.PLIST
----------------------------
1. Click on "Agentic Personal Assistant" project in Navigator
2. Select "Agentic Personal Assistant" target
3. Go to "Info" tab
4. Click "+" button to add new entries:
   
   Key: NSLocationWhenInUseUsageDescription
   Value: We need your location to provide weather information and find nearby places.

STEP 3: BUILD & RUN
------------------
1. Press Cmd+B to build
2. Select simulator (iPhone 15 Pro recommended)
3. Press Cmd+R to run
4. Grant permissions when prompted

STEP 4: TEST FEATURES
--------------------
Try these commands:

✅ "Remind me to study at 6 PM"
   → Should request notification permission and schedule reminder

✅ "What's the weather today?"
   → Should request location permission and show weather

✅ "Find coffee near me"
   → Should open map with coffee shops

✅ "Tell me a joke"
   → Should get response from Claude AI

TROUBLESHOOTING
---------------

❌ "Missing API Key" error?
   → Check Configuration.swift has valid keys

❌ Location not working?
   → Check Info.plist has location permission key
   → Grant permission in Settings

❌ Claude API error?
   → Verify API key is active
   → Check internet connection
   → Ensure you have API credits

❌ Build errors?
   → Clean build folder (Cmd+Shift+K)
   → Rebuild (Cmd+B)

PROJECT STRUCTURE
-----------------

Models/          → Data structures
Services/        → API & device integrations
ViewModels/      → Business logic (MVVM)
Views/           → UI components

NEXT STEPS
----------

1. ✅ Add API keys
2. ✅ Configure Info.plist
3. ✅ Run the app
4. ✅ Test all features
5. 📖 Read README.md for detailed info
6. 🎨 Customize UI colors if desired
7. 🚀 Deploy to TestFlight

IMPORTANT NOTES
---------------

⚠️ API Keys in code are for DEVELOPMENT ONLY
   For production, use:
   - Keychain storage
   - Backend proxy server
   - Environment variables

⚠️ Free API Tiers:
   - OpenWeatherMap: 1000 calls/day
   - Claude API: Check your plan

⚠️ iOS Version:
   - Requires iOS 17.0+
   - SwiftUI with latest features

SUPPORT
-------

If you encounter issues:
1. Check README.md troubleshooting section
2. Verify all API keys are correct
3. Ensure permissions are granted
4. Check Xcode console for errors

Happy coding! 🎉

*/
