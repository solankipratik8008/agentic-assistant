//
//  APP_FLOW_GUIDE.swift
//  Agentic Personal Assistant
//
//  Created by Pratik Solanki on 2026-04-17.
//

/*
 
 ═══════════════════════════════════════════════════════════════════════════
 📱 AGENTIC PERSONAL ASSISTANT - COMPLETE APP FLOW GUIDE
 ═══════════════════════════════════════════════════════════════════════════
 
 This document explains exactly how the app works, from user input to AI response.
 Read this to understand the architecture and debug any issues.
 
 ═══════════════════════════════════════════════════════════════════════════
 
 
 ┌─────────────────────────────────────────────────────────────────────────┐
 │ 1️⃣ APP ARCHITECTURE OVERVIEW                                            │
 └─────────────────────────────────────────────────────────────────────────┘
 
 This app follows MVVM (Model-View-ViewModel) architecture:
 
 ┌──────────┐       ┌──────────────┐       ┌──────────┐
 │   VIEW   │ ◄───► │  VIEW MODEL  │ ◄───► │  MODEL   │
 └──────────┘       └──────────────┘       └──────────┘
       │                    │                     │
       │                    │                     │
   SwiftUI UI         Business Logic        Data Structures
   
 
 📁 PROJECT STRUCTURE:
 
 Models/
 ├── Message.swift                  - Chat message data structure
 ├── UserIntent.swift               - Intent types (reminder, weather, etc.)
 └── WeatherData.swift              - Weather API response models
 
 ViewModels/
 └── ChatViewModel.swift            - Main business logic controller
 
 Views/
 ├── ContentView.swift              - Main chat screen
 ├── Components/
 │   ├── ChatBubbleView.swift       - Individual message bubble
 │   ├── MessageInputView.swift     - Text input + send button
 │   ├── TypingIndicatorView.swift  - Loading animation
 │   └── MapSearchView.swift        - Map interface for navigation
 
 Services/
 ├── ClaudeAPIService.swift         - Claude AI API integration
 ├── IntentDetectionService.swift   - Detects user intent from text
 ├── WeatherService.swift           - OpenWeatherMap API
 ├── LocationService.swift          - GPS/location handling
 ├── NotificationService.swift      - Local notifications/reminders
 └── Configuration.swift            - API keys and app settings
 
 
 ┌─────────────────────────────────────────────────────────────────────────┐
 │ 2️⃣ COMPLETE MESSAGE FLOW (STEP-BY-STEP)                                 │
 └─────────────────────────────────────────────────────────────────────────┘
 
 When a user sends a message, this is what happens:
 
 
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ STEP 1: USER INPUT (ContentView.swift)                                ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
 1. User types in MessageInputView
 2. User taps send button or presses return
 3. MessageInputView calls its `onSend()` closure
 4. ContentView receives the callback:
 
    ```swift
    MessageInputView(
        text: $messageText,
        onSend: {
            let message = messageText
            messageText = ""  // ← Clear input immediately
            Task {
                await viewModel.sendMessage(message)  // ← Send to ViewModel
            }
        }
    )
    ```
 
 5. Text is cleared IMMEDIATELY for better UX
 6. Message is sent to ViewModel asynchronously
 
 
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ STEP 2: VIEW MODEL PROCESSING (ChatViewModel.swift)                   ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
 ChatViewModel.sendMessage() is called:
 
 1. ✅ Validate message is not empty
 2. ➕ Add user message to `messages` array
 3. 🔄 Set `isLoading = true` (shows typing indicator)
 4. 🎯 Detect intent using IntentDetectionService
 5. 🔀 Route to appropriate handler:
 
    ┌─────────────────────┬────────────────────────────────┐
    │ Intent Type         │ Handler Method                 │
    ├─────────────────────┼────────────────────────────────┤
    │ .reminder           │ handleReminderIntent()         │
    │ .weather            │ handleWeatherIntent()          │
    │ .navigation         │ handleNavigationIntent()       │
    │ .general / .unknown │ handleGeneralChat()            │
    └─────────────────────┴────────────────────────────────┘
 
 6. ➕ Add assistant response to `messages` array
 7. 🔄 Set `isLoading = false` (hides typing indicator)
 
 
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ STEP 3: INTENT DETECTION (IntentDetectionService.swift)               ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
 IntentDetectionService uses rule-based keyword matching:
 
 📋 REMINDER DETECTION:
    Keywords: "remind", "reminder", "schedule", "notify", "alert"
    Extracts: Task, Time/Date
    Example: "Remind me to call mom at 3 PM"
             → Intent: .reminder
             → Parameters: {task: "call mom", date: Date(...)}
 
 🌤️ WEATHER DETECTION:
    Keywords: "weather", "temperature", "forecast", "rain", etc.
    Extracts: Location (optional)
    Example: "What's the weather in London?"
             → Intent: .weather
             → Parameters: {location: "London"}
 
 🗺️ NAVIGATION DETECTION:
    Keywords: "map", "navigate", "find", "locate", "near me"
    Extracts: Search query
    Example: "Find coffee shops near me"
             → Intent: .navigation
             → Parameters: {query: "coffee shops"}
 
 💬 GENERAL CHAT:
    Anything else → .general → Routes to Claude AI
 
 
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ STEP 4A: REMINDER FLOW (handleReminderIntent)                         ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
 1. Check notification permission
 2. Extract task and time from parameters
 3. If missing info → Ask Claude to help extract it
 4. Schedule local notification via NotificationService
 5. Add confirmation message to chat
 
 
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ STEP 4B: WEATHER FLOW (handleWeatherIntent)                           ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
 1. Check if location specified or use GPS
 2. Request location permission if needed
 3. Call WeatherService.fetchWeather()
 4. Format weather data into readable text
 5. Add weather summary to chat
 
 
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ STEP 4C: NAVIGATION FLOW (handleNavigationIntent)                     ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
 1. Extract search query
 2. Set mapQuery in ViewModel
 3. Set showMapSheet = true
 4. SwiftUI presents MapSearchView as sheet
 5. MapSearchView searches via MKLocalSearch
 6. Display results on map + list
 
 
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ STEP 4D: GENERAL CHAT FLOW (handleGeneralChat)                        ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
 This is the most important flow for conversational AI!
 
 1. Get last 10 messages for context
 2. Call ClaudeAPIService.sendMessage()
 3. Wait for AI response
 4. Add response to chat
 5. If API fails → Show helpful fallback message
 
 
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ STEP 5: CLAUDE API CALL (ClaudeAPIService.swift)                      ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
 How Claude integration works:
 
 1. Convert our Message models to Claude's format
 2. Create HTTP request to: https://api.anthropic.com/v1/messages
 3. Add required headers:
    - x-api-key: YOUR_API_KEY
    - anthropic-version: 2023-06-01
    - content-type: application/json
 
 4. Send JSON body:
    ```json
    {
      "model": "claude-3-5-sonnet-20241022",
      "max_tokens": 1024,
      "messages": [
        {"role": "user", "content": "Hello!"},
        {"role": "assistant", "content": "Hi there!"},
        {"role": "user", "content": "How are you?"}
      ]
    }
    ```
 
 5. Receive response:
    ```json
    {
      "id": "msg_...",
      "type": "message",
      "role": "assistant",
      "content": [
        {"type": "text", "text": "I'm doing great!"}
      ],
      "model": "claude-3-5-sonnet-20241022",
      "stop_reason": "end_turn",
      "usage": {"input_tokens": 15, "output_tokens": 8}
    }
    ```
 
 6. Extract text from content array
 7. Return to ViewModel
 
 
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ STEP 6: UI UPDATE (SwiftUI automatic binding)                         ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
 Because ChatViewModel is @ObservableObject with @Published properties:
 
 1. When messages array changes → UI automatically updates
 2. New ChatBubbleView appears for each message
 3. ScrollView auto-scrolls to bottom
 4. Typing indicator hides when isLoading = false
 
 This is the magic of SwiftUI! ✨
 
 
 ┌─────────────────────────────────────────────────────────────────────────┐
 │ 3️⃣ DATA FLOW DIAGRAM                                                    │
 └─────────────────────────────────────────────────────────────────────────┘
 
 User Types Message
       ↓
 MessageInputView.onSend()
       ↓
 ContentView captures text & clears field
       ↓
 ChatViewModel.sendMessage(text)
       ↓
 Add user message to array → UI updates
       ↓
 IntentDetectionService.detectIntent()
       ↓
 ┌───────────────────────────────────────────────────┐
 │  Route based on intent:                           │
 │                                                    │
 │  ┌─────────────┐  ┌────────────┐  ┌────────────┐ │
 │  │  Reminder   │  │  Weather   │  │ Navigation │ │
 │  └──────┬──────┘  └─────┬──────┘  └─────┬──────┘ │
 │         │               │               │        │
 │         ↓               ↓               ↓        │
 │  NotificationSvc  WeatherService   MapSheet     │
 │                                                   │
 │  ┌──────────────────────────────────────────┐    │
 │  │  General Chat → ClaudeAPIService         │    │
 │  └────────────────┬─────────────────────────┘    │
 │                   ↓                               │
 │            Claude API (HTTP)                      │
 │                   ↓                               │
 │            AI Response                            │
 └───────────────────┼───────────────────────────────┘
                     ↓
 Add assistant message to array
                     ↓
 UI updates automatically
                     ↓
 User sees response!
 
 
 ┌─────────────────────────────────────────────────────────────────────────┐
 │ 4️⃣ KEY CONCEPTS & TECHNOLOGIES                                          │
 └─────────────────────────────────────────────────────────────────────────┘
 
 🔷 MVVM Architecture
    - Model: Data structures (Message, WeatherData, etc.)
    - View: SwiftUI views (ContentView, ChatBubbleView)
    - ViewModel: Business logic (ChatViewModel)
 
 🔷 SwiftUI Bindings
    - @StateObject: ViewModel owned by view
    - @Published: Properties that trigger UI updates
    - @Binding: Two-way data connection
    - @State: View-local state
 
 🔷 Swift Concurrency
    - async/await: Modern asynchronous code
    - Task: Launch async work from sync context
    - @MainActor: Ensure UI updates on main thread
 
 🔷 Combine (indirectly via @Published)
    - ObservableObject protocol
    - Automatic view updates
 
 🔷 Services Layer
    - Singleton pattern (.shared)
    - Separation of concerns
    - Testable, reusable logic
 
 
 ┌─────────────────────────────────────────────────────────────────────────┐
 │ 5️⃣ DEBUGGING GUIDE                                                      │
 └─────────────────────────────────────────────────────────────────────────┘
 
 The app has extensive logging! Check Xcode console for:
 
 🔍 Message Send Flow:
    📤 [ChatViewModel] sendMessage called with: "..."
    ✅ [ChatViewModel] User message added. Total messages: X
    🔍 [ChatViewModel] Detecting intent...
    🎯 [ChatViewModel] Detected intent: general (confidence: 1.0)
    💬 [ChatViewModel] Handling general chat
    🌐 [ClaudeAPI] sendMessage called with X messages
    📤 [ClaudeAPI] Sending X messages to Claude
    ⏳ [ClaudeAPI] Waiting for response...
    📊 [ClaudeAPI] Received HTTP 200
    ✅ [ClaudeAPI] Successfully received response
    ✅ [ChatViewModel] Intent handling completed
    🏁 [ChatViewModel] sendMessage completed. Total messages: X
 
 ❌ Common Issues:
 
 1. "API key is missing"
    → Fix: Add your Claude API key in Configuration.swift
 
 2. "HTTP 401"
    → Fix: Check API key is valid
 
 3. "Network error"
    → Fix: Check internet connection
    → Fix: Check API endpoint is correct
 
 4. "No response appears"
    → Check console for errors
    → Verify isLoading changes back to false
    → Check messages array in debugger
 
 5. "UI doesn't update"
    → Ensure ChatViewModel is @MainActor
    → Check @Published on messages array
    → Verify ContentView uses @StateObject
 
 
 ┌─────────────────────────────────────────────────────────────────────────┐
 │ 6️⃣ EXTENDING THE APP                                                    │
 └─────────────────────────────────────────────────────────────────────────┘
 
 Want to add a new capability? Here's how:
 
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ EXAMPLE: Add a "Calendar" Feature                                     ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 
 Step 1: Add intent type
    → UserIntent.swift
    → Add: case calendar
 
 Step 2: Create service
    → Create: Services/CalendarService.swift
    → Implement: func addEvent(...) async throws
 
 Step 3: Update intent detection
    → IntentDetectionService.swift
    → Add calendar keywords
    → Add extraction logic
 
 Step 4: Add handler in ViewModel
    → ChatViewModel.swift
    → Add: private func handleCalendarIntent(...)
    → Add case in switch statement
 
 Step 5: Test!
    → User: "Add meeting tomorrow at 2 PM"
    → Should detect .calendar intent
    → Should call CalendarService
    → Should add event
    → Should reply with confirmation
 
 
 ┌─────────────────────────────────────────────────────────────────────────┐
 │ 7️⃣ API KEYS SETUP                                                       │
 └─────────────────────────────────────────────────────────────────────────┘
 
 This app needs two API keys:
 
 1. Claude API (for AI chat)
    → Get from: https://console.anthropic.com/
    → Add to: Configuration.swift → claudeAPIKey
 
 2. OpenWeatherMap API (for weather)
    → Get from: https://openweathermap.org/api
    → Add to: Configuration.swift → weatherAPIKey
 
 ⚠️ IMPORTANT: In production apps, use:
    - Keychain for secure storage
    - Environment variables
    - Backend proxy to hide keys
 
 This demo uses Configuration.swift for simplicity.
 
 
 ┌─────────────────────────────────────────────────────────────────────────┐
 │ 8️⃣ PERMISSION REQUIREMENTS                                              │
 └─────────────────────────────────────────────────────────────────────────┘
 
 Add these to Info.plist:
 
 1. Location:
    - NSLocationWhenInUseUsageDescription
    - "We need your location to show weather and nearby places"
 
 2. Notifications:
    - Requested at runtime via UNUserNotificationCenter
 
 
 ┌─────────────────────────────────────────────────────────────────────────┐
 │ 9️⃣ TESTING SCENARIOS                                                    │
 └─────────────────────────────────────────────────────────────────────────┘
 
 Test these to verify everything works:
 
 ✅ General Chat:
    User: "Hello!"
    Expected: AI greeting response
 
 ✅ Weather (current location):
    User: "What's the weather?"
    Expected: Weather info for current location
 
 ✅ Weather (specific city):
    User: "What's the weather in Paris?"
    Expected: Weather info for Paris
 
 ✅ Reminder (specific time):
    User: "Remind me to call mom at 6 PM"
    Expected: Confirmation, notification scheduled
 
 ✅ Reminder (relative time):
    User: "Remind me to check email in 30 minutes"
    Expected: Confirmation, notification scheduled
 
 ✅ Navigation:
    User: "Find coffee near me"
    Expected: Map opens with coffee shop results
 
 ✅ Error Handling:
    Disable internet → Send message
    Expected: Fallback message appears
 
 
 ┌─────────────────────────────────────────────────────────────────────────┐
 │ 🔟 PERFORMANCE CONSIDERATIONS                                            │
 └─────────────────────────────────────────────────────────────────────────┘
 
 - Messages limited to last 10 for API calls (reduce tokens)
 - LazyVStack for efficient message rendering
 - Async/await prevents UI blocking
 - Services are singletons (prevent duplication)
 
 
 ┌─────────────────────────────────────────────────────────────────────────┐
 │ 📝 FINAL NOTES                                                           │
 └─────────────────────────────────────────────────────────────────────────┘
 
 This app demonstrates:
 ✅ Clean MVVM architecture
 ✅ Modern SwiftUI patterns
 ✅ Swift Concurrency (async/await)
 ✅ REST API integration
 ✅ Rule-based + AI hybrid approach
 ✅ Error handling & fallbacks
 ✅ Comprehensive logging for debugging
 
 The code is production-ready but simplified for learning.
 In a real production app, you would add:
 - Keychain for API keys
 - More robust error handling
 - Persistence (save chat history)
 - Unit tests
 - UI tests
 - Analytics
 - Accessibility improvements
 
 ═══════════════════════════════════════════════════════════════════════════
 
 If you have questions or encounter issues:
 1. Check the console logs
 2. Verify API keys are set
 3. Check internet connection
 4. Review this guide
 5. Add more print() statements to trace execution
 
 Happy coding! 🚀
 
 ═══════════════════════════════════════════════════════════════════════════
 
 */
