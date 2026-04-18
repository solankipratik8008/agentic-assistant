# Agentic Personal Assistant

A production-level iOS app built with SwiftUI that provides an AI-powered personal assistant with advanced capabilities.

## 🎯 Features

### 1. **Intelligent Chat Interface**
- Clean, modern ChatGPT-like UI
- Message bubbles with timestamps
- Typing indicators
- Smooth scrolling and animations

### 2. **AI-Powered Agent System**
- Intent detection (Reminders, Weather, Navigation, General Chat)
- Claude API integration for natural language understanding
- Context-aware responses
- Multi-step task execution

### 3. **Smart Tools**
- **Weather**: Fetch current weather by location or city name
- **Location**: GPS-based location services
- **Reminders**: Schedule local notifications
- **Maps**: Search and navigate to places

### 4. **Example Use Cases**
- "Remind me to study at 6 PM" → Creates local notification
- "What's the weather today?" → Fetches weather data
- "Find parking near me" → Opens map with search results
- "Tell me a joke" → Claude AI responds naturally

## 📁 Project Structure

```
Agentic Personal Assistant/
├── Models/
│   ├── Message.swift              # Chat message models + Claude API models
│   ├── UserIntent.swift           # Intent detection & task models
│   └── WeatherData.swift          # Weather API models
│
├── Services/
│   ├── ClaudeAPIService.swift     # Claude AI integration
│   ├── WeatherService.swift       # OpenWeatherMap API
│   ├── LocationService.swift      # Core Location wrapper
│   ├── NotificationService.swift  # Local notifications
│   ├── IntentDetectionService.swift # Intent parsing
│   └── Configuration.swift        # API keys & settings
│
├── ViewModels/
│   └── ChatViewModel.swift        # Main chat logic (MVVM)
│
├── Views/
│   ├── ContentView.swift          # Main chat screen
│   └── Components/
│       ├── ChatBubbleView.swift   # Message bubble UI
│       ├── MessageInputView.swift # Text input field
│       ├── TypingIndicatorView.swift
│       └── MapSearchView.swift    # Map search interface
│
└── Agentic_Personal_AssistantApp.swift
```

## 🚀 Setup Instructions

### Step 1: API Keys

#### Claude API Key
1. Sign up at [Anthropic Console](https://console.anthropic.com/)
2. Create an API key
3. Open `Services/Configuration.swift`
4. Add your key:
   ```swift
   static let claudeAPIKey = "sk-ant-your-api-key-here"
   ```

#### Weather API Key
1. Sign up at [OpenWeatherMap](https://openweathermap.org/api)
2. Get a free API key
3. Add to `Services/Configuration.swift`:
   ```swift
   static let weatherAPIKey = "your-openweather-api-key"
   ```

### Step 2: Info.plist Configuration

Add required permissions to your `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to provide weather information and find nearby places.</string>
```

**How to add:**
1. In Xcode, select your project
2. Select the "Agentic Personal Assistant" target
3. Go to "Info" tab
4. Click "+" to add new entries
5. Add the key above

### Step 3: Build and Run

1. Open `Agentic Personal Assistant.xcodeproj` in Xcode
2. Select a simulator or device
3. Build and run (Cmd+R)

## 🏗️ Architecture: MVVM

### Models
- Pure data structures
- API request/response models
- Business logic data

### Views
- SwiftUI components
- No business logic
- Purely presentational

### ViewModels
- `@MainActor` classes
- `ObservableObject` for state management
- Coordinate between Services and Views

### Services
- API integrations
- Device capabilities (Location, Notifications)
- Reusable business logic

## 💡 Usage Examples

### Setting Reminders
```
User: "Remind me to study at 6 PM"
AI: ✅ Reminder set! I'll notify you to "study" on Apr 17, 2026 at 6:00 PM.
```

### Checking Weather
```
User: "What's the weather in San Francisco?"
AI: 📍 San Francisco
    🌡️ Temperature: 18.5°C (feels like 17.2°C)
    ☁️ Condition: Clouds - Partly cloudy
    💧 Humidity: 65%
    💨 Wind Speed: 4.2 m/s
```

### Finding Places
```
User: "Find parking near me"
AI: 🗺️ Opening map to search for: parking
[Map opens with nearby parking locations]
```

### General Chat
```
User: "Tell me a joke"
AI: Why did the programmer quit his job?
    Because he didn't get arrays! 😄
```

## 🔒 Security Notes

### Current Implementation (Development)
- API keys stored in `Configuration.swift`
- **⚠️ NOT suitable for production**

### Production Recommendations
1. **Keychain**: Store API keys in iOS Keychain
2. **Backend Proxy**: Call Claude API from your server
3. **Environment Variables**: Use build configurations
4. **Code Obfuscation**: Protect sensitive data

### Example Keychain Implementation
```swift
// Use KeychainAccess or Security framework
import KeychainAccess

let keychain = Keychain(service: "com.yourapp.assistant")
keychain["claudeAPIKey"] = "your-api-key"
```

## 📱 Supported iOS Features

- ✅ SwiftUI (iOS 17+)
- ✅ Swift Concurrency (async/await)
- ✅ Core Location
- ✅ MapKit
- ✅ UserNotifications
- ✅ Combine (via @Published)

## 🧪 Testing

### Manual Testing Checklist
- [ ] Send a message and receive AI response
- [ ] Set reminder with time parsing
- [ ] Check weather with location
- [ ] Check weather with city name
- [ ] Search for places on map
- [ ] Handle location permission denied
- [ ] Handle notification permission denied
- [ ] Handle API errors gracefully

### Unit Tests (TODO)
```swift
// Example test structure
import Testing

@Suite("Intent Detection Tests")
struct IntentDetectionTests {
    @Test("Detect reminder intent")
    func detectReminderIntent() async throws {
        let service = IntentDetectionService.shared
        let intent = service.detectIntent(from: "Remind me to study at 6 PM")
        #expect(intent.intent == .reminder)
    }
}
```

## 🛠️ Customization

### Change AI Model
Edit `ClaudeAPIService.swift`:
```swift
private let model = "claude-3-5-sonnet-20241022" // Change model here
```

### Adjust Message History
Edit `Configuration.swift`:
```swift
static let maxMessageHistory = 50 // Increase/decrease
```

### Customize UI Colors
Edit `ChatBubbleView.swift`:
```swift
private var backgroundColor: Color {
    isUser ? Color.purple : Color(.systemGray5) // Change user bubble color
}
```

## 📚 API Documentation

### Claude API
- [Anthropic Documentation](https://docs.anthropic.com/)
- Model: Claude 3.5 Sonnet
- Rate Limits: Check your console

### Weather API
- [OpenWeatherMap Docs](https://openweathermap.org/api)
- Free tier: 1000 calls/day
- Units: Metric (Celsius)

## 🐛 Troubleshooting

### "Missing API Key" Error
- Check `Configuration.swift` has valid keys
- Ensure no extra spaces in the key string

### Location Not Working
- Check Info.plist has location usage description
- Grant permission when prompted
- Check device settings

### Notifications Not Scheduling
- Grant notification permission
- Check date is in the future
- Verify in Settings > Notifications

### API Errors
- Check internet connection
- Verify API keys are active
- Check API service status

## 🚀 Future Enhancements

- [ ] Core Data for persistent chat history
- [ ] Voice input with Speech framework
- [ ] Calendar integration
- [ ] Email/Message composition
- [ ] Multi-language support
- [ ] Widget for quick access
- [ ] Siri Shortcuts integration
- [ ] iCloud sync across devices

## 📄 License

This project is for educational purposes. Ensure compliance with:
- Anthropic API Terms of Service
- OpenWeatherMap API Terms
- Apple Developer Agreement

## 👨‍💻 Developer

Created by Pratik Solanki on April 17, 2026

---

**Ready to build?** Follow the setup instructions above and start chatting with your AI assistant! 🎉
