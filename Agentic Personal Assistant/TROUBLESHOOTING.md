# Troubleshooting Guide

## 🔧 Common Issues and Solutions

---

### 1. 🚫 "Missing API Key" Error

**Problem:** App shows error message about missing API keys

**Solutions:**
1. Open `Services/Configuration.swift`
2. Verify both API keys are filled:
   ```swift
   static let claudeAPIKey = "sk-ant-api03-xxxxx"  // Must not be empty
   static let weatherAPIKey = "your-key-here"       // Must not be empty
   ```
3. Make sure there are no extra spaces
4. Rebuild the app (Cmd+Shift+K, then Cmd+B)

---

### 2. 🌐 Claude API Errors

**Problem:** "Invalid API Key" or "Authentication Failed"

**Solutions:**

**Check #1: Verify API Key**
- Go to https://console.anthropic.com/
- Navigate to API Keys section
- Verify your key is active
- Copy it again to be sure

**Check #2: API Credits**
- Check your Anthropic account balance
- Ensure you have credits available
- Some accounts need credit card for API access

**Check #3: Internet Connection**
- Verify you're connected to internet
- Try on WiFi instead of cellular
- Disable VPN if active

**Check #4: API Status**
- Visit https://status.anthropic.com/
- Check if API is operational

**Check #5: Rate Limits**
- You might be making too many requests
- Wait a few minutes and try again
- Free tier has strict rate limits

---

### 3. 🌤️ Weather API Not Working

**Problem:** "Failed to fetch weather" or "Invalid response"

**Solutions:**

**Check #1: API Key Activation**
- Weather API keys take 10-15 minutes to activate after signup
- Wait and try again
- Log into OpenWeatherMap to verify key status

**Check #2: API Key Format**
- Verify you copied the entire key
- No extra spaces before or after
- Key should be alphanumeric

**Check #3: Rate Limits**
- Free tier: 60 calls/minute, 1000 calls/day
- Wait a minute if you hit the limit

**Check #4: Location Issues**
- Try with a specific city: "weather in London"
- If using "weather today" (GPS), check location permissions

---

### 4. 📍 Location Services Not Working

**Problem:** "Location permission not granted" or location not found

**Solutions:**

**Check #1: Info.plist**
1. Select project in Navigator
2. Select target
3. Go to Info tab
4. Verify this key exists:
   - `NSLocationWhenInUseUsageDescription`
   - Value: "We need your location to provide weather information and find nearby places."

**Check #2: System Permissions**
1. iOS Settings → Privacy & Security → Location Services
2. Find "Agentic Personal Assistant"
3. Set to "While Using the App"

**Check #3: Simulator Issues**
- Location doesn't work well on simulator
- Try on a real device
- Or in simulator: Features → Location → Apple (or Custom Location)

**Check #4: Code**
- Verify `LocationService.swift` is in your project
- Check that `requestAuthorization()` is being called

---

### 5. 🔔 Notifications Not Scheduling

**Problem:** "Notification permission not granted" or reminders not appearing

**Solutions:**

**Check #1: Permission**
- App should prompt for permission on first reminder
- If denied, go to: Settings → Notifications → Agentic Personal Assistant
- Enable "Allow Notifications"

**Check #2: Time is in Future**
- Can't schedule notifications in the past
- "Remind me to study at 6 PM" schedules for today or tomorrow at 6 PM
- If it's already past 6 PM today, it schedules for tomorrow

**Check #3: Simulator Limitations**
- Notifications work best on real devices
- Simulator sometimes doesn't show them properly
- Use Console app to see notification logs

**Check #4: Check Pending Notifications**
```swift
// In NotificationService, use:
let pending = await getPendingNotifications()
print("Pending notifications: \(pending.count)")
```

---

### 6. 🗺️ Map Not Opening

**Problem:** Map sheet doesn't appear when asking for navigation

**Solutions:**

**Check #1: Query Detection**
- Make sure you use keywords: "find", "locate", "show", "near me"
- Examples:
  - ✅ "Find parking near me"
  - ✅ "Locate coffee shops"
  - ❌ "I need coffee" (too vague)

**Check #2: Location Permission**
- Map works better with location access
- Grant location permission for better results

**Check #3: MapKit**
- Verify `MapSearchView.swift` is in project
- Check that `import MapKit` is present

---

### 7. 💬 AI Not Responding

**Problem:** Message sent but no response from assistant

**Solutions:**

**Check #1: Loading Indicator**
- Look for three animated dots
- If stuck loading, there might be a network timeout
- Pull down to refresh or restart app

**Check #2: Error Alert**
- App should show error alert if API fails
- Read the error message for clues

**Check #3: Console Logs**
- Open Xcode console (Cmd+Shift+Y)
- Look for error messages
- Check network logs

**Check #4: Message Format**
- Make sure message isn't empty
- Try a simple message: "Hello"

---

### 8. 🎨 UI Issues

**Problem:** Layout looks wrong or text is cut off

**Solutions:**

**Check #1: Device/Simulator**
- Test on different screen sizes
- iPhone SE (small) vs iPhone 15 Pro Max (large)

**Check #2: Dynamic Type**
- Settings → Accessibility → Display & Text Size
- Reduce text size if needed

**Check #3: Rebuild**
- Clean build folder (Cmd+Shift+K)
- Rebuild (Cmd+B)
- Restart simulator/app

---

### 9. 🏗️ Build Errors

**Problem:** Project won't build in Xcode

**Solutions:**

**Check #1: File Organization**
- All files should be in correct folders
- Models/, Services/, Views/, ViewModels/

**Check #2: Missing Imports**
- Verify all files have necessary imports:
  - `import SwiftUI`
  - `import Foundation`
  - `import MapKit` (for map files)
  - `import CoreLocation` (for location files)

**Check #3: Target Membership**
- Select each file in Navigator
- Check File Inspector (right panel)
- Ensure it's part of the app target

**Check #4: Clean Build**
- Product → Clean Build Folder (Cmd+Shift+K)
- Close and reopen Xcode
- Build again (Cmd+B)

---

### 10. 🐌 App is Slow or Laggy

**Problem:** UI is unresponsive or animations stutter

**Solutions:**

**Check #1: Message History**
- Too many messages can slow down scroll
- Clear chat periodically
- Consider implementing pagination

**Check #2: API Calls**
- Each message makes an API call
- On slow internet, this takes time
- Consider caching responses

**Check #3: Memory**
- Open Xcode Instruments (Cmd+I)
- Choose "Leaks" or "Allocations"
- Check for memory leaks

**Check #4: Main Thread**
- Verify async operations use `await`
- Don't block main thread
- UI updates must be on `@MainActor`

---

### 11. 📱 Testing on Real Device

**Problem:** Works on simulator but not on device

**Solutions:**

**Check #1: Signing & Capabilities**
- Select project in Navigator
- Go to Signing & Capabilities
- Select your Apple ID team
- Fix any signing errors

**Check #2: Deployment Target**
- Check minimum iOS version
- Device must run iOS 17.0+

**Check #3: Internet Access**
- Device needs internet for API calls
- Check WiFi/cellular connection

**Check #4: Permissions**
- Grant all permissions when prompted
- Location, Notifications

---

### 12. 🔍 Intent Detection Not Working

**Problem:** App doesn't recognize commands like "remind me" or "weather"

**Solutions:**

**Check #1: Keywords**
Use these exact keywords:

**Reminders:**
- "remind me to..."
- "reminder to..."
- "schedule..."

**Weather:**
- "weather"
- "temperature"
- "forecast"

**Navigation:**
- "find..."
- "locate..."
- "show me..."
- "near me"

**Check #2: Sentence Structure**
- "Remind me to study at 6 PM" ✅
- "study reminder 6pm" ❌ (too vague)

**Check #3: Debug Intent**
Add logging to `IntentDetectionService.swift`:
```swift
func detectIntent(from message: String) -> DetectedIntent {
    print("Detecting intent for: \(message)")
    let intent = // ... existing code
    print("Detected: \(intent.intent)")
    return intent
}
```

---

## 🆘 Still Having Issues?

### Debug Checklist:

1. **Clean Build**
   - Cmd+Shift+K (Clean)
   - Cmd+B (Build)

2. **Restart Xcode**
   - Quit Xcode completely
   - Reopen project

3. **Reset Simulator**
   - Device → Erase All Content and Settings
   - Reinstall app

4. **Check Console**
   - Cmd+Shift+Y to show console
   - Look for error messages

5. **Verify Files**
   - All files from this guide are in project
   - No missing files
   - All imports correct

6. **Test Incrementally**
   - Try one feature at a time
   - General chat first (simplest)
   - Then weather, reminders, maps

---

## 📞 Getting Help

### Resources:

1. **README.md** - Complete setup guide
2. **QUICK_START_GUIDE.swift** - Quick reference
3. **ARCHITECTURE.md** - How the app is structured
4. **APIKeySetup.swift** - API key instructions

### External Help:

1. **Claude API Issues:**
   - https://docs.anthropic.com/
   - support@anthropic.com

2. **Weather API Issues:**
   - https://openweathermap.org/faq
   - Contact support through website

3. **Apple Frameworks:**
   - https://developer.apple.com/documentation/
   - Apple Developer Forums

---

## 🐛 Reporting Bugs

If you find a bug in the code:

1. Note the exact error message
2. Note what you were trying to do
3. Check Xcode console for stack trace
4. Try to reproduce it consistently
5. Document steps to reproduce

---

## ✅ Verification Steps

After fixing any issue:

1. ✅ Clean build (Cmd+Shift+K)
2. ✅ Rebuild (Cmd+B)
3. ✅ Run app (Cmd+R)
4. ✅ Test the specific feature
5. ✅ Test all other features (regression)
6. ✅ Test on different devices/simulators

---

**Most issues are caused by:**
1. Missing or incorrect API keys (80%)
2. Missing Info.plist entries (10%)
3. Permission not granted (5%)
4. Network issues (5%)

**Start with the basics and work your way up!** 🎯
