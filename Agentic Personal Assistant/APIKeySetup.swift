//
//  APIKeySetup.swift
//  Configuration Helper
//
//  THIS FILE HELPS YOU SET UP API KEYS
//

/*

╔══════════════════════════════════════════════════════════════════════╗
║                      API KEY SETUP GUIDE                             ║
╚══════════════════════════════════════════════════════════════════════╝

You need TWO API keys to run this app:

1️⃣  CLAUDE API KEY (from Anthropic)
2️⃣  WEATHER API KEY (from OpenWeatherMap)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1️⃣  GETTING CLAUDE API KEY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1: Go to https://console.anthropic.com/
Step 2: Sign up or log in
Step 3: Navigate to "API Keys" section
Step 4: Click "Create Key"
Step 5: Copy the key (it looks like: sk-ant-api03-xxxxx...)
Step 6: Open: Services/Configuration.swift
Step 7: Replace the empty string:

   Before:
   static let claudeAPIKey = ""
   
   After:
   static let claudeAPIKey = "sk-ant-api03-your-actual-key-here"

⚠️  IMPORTANT NOTES:
   • Keep your API key secret
   • Don't commit it to public repositories
   • Check your usage limits and pricing
   • Claude API has rate limits

💰 PRICING (as of 2026):
   • Claude 3.5 Sonnet: ~$3 per million input tokens
   • First $5 of usage might be free (check current promotions)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

2️⃣  GETTING WEATHER API KEY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1: Go to https://openweathermap.org/api
Step 2: Click "Sign Up" (it's FREE!)
Step 3: Verify your email
Step 4: Go to "API Keys" in your account
Step 5: Copy your default API key (or create a new one)
Step 6: Open: Services/Configuration.swift
Step 7: Replace the empty string:

   Before:
   static let weatherAPIKey = ""
   
   After:
   static let weatherAPIKey = "your-actual-weather-api-key-here"

⚠️  IMPORTANT NOTES:
   • Free tier: 1,000 calls/day, 60 calls/minute
   • API key activates in ~10 minutes after signup
   • Don't share your API key publicly

💰 PRICING:
   • Free tier: Perfect for development
   • 1,000 API calls per day
   • Sufficient for personal use

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VERIFICATION CHECKLIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Before building, verify:

[ ] Services/Configuration.swift has both API keys
[ ] Info.plist has location permission string
[ ] Build settings are correct
[ ] Simulator/device is selected
[ ] Internet connection is available

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TESTING YOUR SETUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Build the app (Cmd+B)
2. Run on simulator (Cmd+R)
3. Try each feature:

   ✅ General Chat:
      Type: "Hello, how are you?"
      Expected: Claude AI responds
      
   ✅ Weather:
      Type: "What's the weather in London?"
      Expected: Shows weather data
      
   ✅ Reminder:
      Type: "Remind me to test the app in 5 minutes"
      Expected: Notification permission prompt, then confirmation
      
   ✅ Navigation:
      Type: "Find coffee near me"
      Expected: Map opens with coffee shops

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

COMMON ERRORS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

❌ "Missing API Key" error
   → Check Configuration.swift has non-empty strings
   → Make sure you copied the full key
   
❌ "Invalid API Key" error
   → Double-check you copied the correct key
   → Verify key is active in your account
   → For Weather API: wait 10 minutes after signup
   
❌ "Rate limit exceeded"
   → You've made too many requests
   → Claude: Check your plan limits
   → Weather: Free tier is 60 calls/minute
   
❌ Network errors
   → Check internet connection
   → Verify firewall/VPN isn't blocking requests
   → Try on real device instead of simulator

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SECURITY BEST PRACTICES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For PRODUCTION apps:

1. NEVER commit API keys to Git
   → Add Configuration.swift to .gitignore
   → Or use environment variables
   
2. Use Keychain for storage
   ```swift
   import Security
   
   func saveAPIKey(_ key: String, service: String) {
       let data = key.data(using: .utf8)!
       let query: [String: Any] = [
           kSecClass as String: kSecClassGenericPassword,
           kSecAttrService as String: service,
           kSecValueData as String: data
       ]
       SecItemAdd(query as CFDictionary, nil)
   }
   ```
   
3. Use Backend Proxy
   → Call Claude API from your server
   → Server validates requests
   → Client only calls your API
   
4. Implement Usage Limits
   → Track API calls per user
   → Prevent abuse
   → Show usage to users

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ALTERNATIVE: USING .env FILE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For better security in development:

1. Create a .env file (add to .gitignore):
   ```
   CLAUDE_API_KEY=sk-ant-api03-xxxxx
   WEATHER_API_KEY=your-weather-key
   ```

2. Use SwiftGen or similar to read it
3. Load at build time
4. Never commit .env file

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

READY TO START?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. ✅ Get Claude API key
2. ✅ Get Weather API key
3. ✅ Add both to Configuration.swift
4. ✅ Build and run
5. 🎉 Start chatting with your AI assistant!

╔══════════════════════════════════════════════════════════════════════╗
║                         NEED HELP?                                   ║
║                  Check README.md for more info                       ║
╚══════════════════════════════════════════════════════════════════════╝

*/
