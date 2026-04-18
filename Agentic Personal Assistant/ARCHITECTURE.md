# Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        USER INTERFACE (SwiftUI)                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                     ContentView.swift                       │    │
│  │  - Main chat screen                                         │    │
│  │  - NavigationStack                                          │    │
│  │  - Sheet for MapSearchView                                  │    │
│  └────────────────────┬───────────────────────────────────────┘    │
│                       │                                             │
│  ┌────────────────────┴───────────────────────────────────────┐    │
│  │              REUSABLE COMPONENTS                            │    │
│  ├─────────────────────────────────────────────────────────────┤    │
│  │  • ChatBubbleView    → Message bubble UI                    │    │
│  │  • MessageInputView  → Text field + send button             │    │
│  │  • TypingIndicator   → Animated dots while loading          │    │
│  │  • MapSearchView     → MapKit integration                   │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└──────────────────────────────┬───────────────────────────────────────┘
                               │
                               │ Binding / @StateObject
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    VIEW MODEL LAYER (MVVM)                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                  ChatViewModel.swift                        │    │
│  │  @MainActor @ObservableObject                               │    │
│  │                                                              │    │
│  │  @Published Properties:                                     │    │
│  │    • messages: [Message]                                    │    │
│  │    • isLoading: Bool                                        │    │
│  │    • errorMessage: String?                                  │    │
│  │    • showMapSheet: Bool                                     │    │
│  │                                                              │    │
│  │  Methods:                                                   │    │
│  │    • sendMessage(_:)                                        │    │
│  │    • handleReminderIntent()                                 │    │
│  │    • handleWeatherIntent()                                  │    │
│  │    • handleNavigationIntent()                               │    │
│  │    • handleGeneralChat()                                    │    │
│  └────────────┬─────────────────────────────────────────────────┘    │
│               │                                                      │
└───────────────┼──────────────────────────────────────────────────────┘
                │
                │ Coordinates Services
                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        SERVICE LAYER                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │            IntentDetectionService.swift                     │    │
│  │  • detectIntent(from: String) → DetectedIntent              │    │
│  │  • Extract parameters (task, date, location, query)         │    │
│  │  • Pattern matching with Regex                              │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │             ClaudeAPIService.swift                          │    │
│  │  • sendMessage() → Claude API call                          │    │
│  │  • URL: api.anthropic.com/v1/messages                       │    │
│  │  • Model: claude-3-5-sonnet-20241022                        │    │
│  │  • Error handling                                           │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │              WeatherService.swift                           │    │
│  │  • fetchWeather(for: city)                                  │    │
│  │  • fetchWeather(lat, lon)                                   │    │
│  │  • URL: api.openweathermap.org/data/2.5/weather            │    │
│  │  • Returns: FormattedWeather                                │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │             LocationService.swift                           │    │
│  │  • CLLocationManager wrapper                                │    │
│  │  • getCurrentLocation() → CLLocation                        │    │
│  │  • getCityName() → String                                   │    │
│  │  • Handle authorization                                     │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │           NotificationService.swift                         │    │
│  │  • UNUserNotificationCenter wrapper                         │    │
│  │  • scheduleNotification()                                   │    │
│  │  • Request authorization                                    │    │
│  │  • Manage pending notifications                             │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└──────────────────────────────┬───────────────────────────────────────┘
                               │
                               │ Uses Models
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          MODEL LAYER                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                    Message.swift                            │    │
│  │  • Message (id, role, content, timestamp)                   │    │
│  │  • ClaudeRequest / ClaudeResponse                           │    │
│  │  • ClaudeMessage, ClaudeContent                             │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                  UserIntent.swift                           │    │
│  │  • UserIntent enum (reminder, weather, navigation)          │    │
│  │  • DetectedIntent (intent, parameters, confidence)          │    │
│  │  • AgentTask, TaskStep, TaskAction                          │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                 WeatherData.swift                           │    │
│  │  • WeatherResponse (API response)                           │    │
│  │  • FormattedWeather (app-friendly format)                   │    │
│  │  • Helper models (Coordinates, MainWeather, etc.)           │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════
                            DATA FLOW
═══════════════════════════════════════════════════════════════════════

1. USER INPUT
   ├─> User types message in MessageInputView
   └─> onSend() triggers

2. VIEW → VIEWMODEL
   ├─> ContentView calls viewModel.sendMessage(text)
   └─> Message added to messages array

3. VIEWMODEL → SERVICES
   ├─> IntentDetectionService.detectIntent()
   │   └─> Returns: DetectedIntent (intent type + parameters)
   │
   ├─> Based on intent:
   │   ├─> Reminder → NotificationService.scheduleNotification()
   │   ├─> Weather → LocationService + WeatherService
   │   ├─> Navigation → Show MapSearchView
   │   └─> General → ClaudeAPIService.sendMessage()
   │
   └─> Response added to messages

4. VIEWMODEL → VIEW
   ├─> @Published messages updates
   ├─> SwiftUI automatically re-renders
   └─> ScrollView scrolls to bottom

═══════════════════════════════════════════════════════════════════════
                         KEY TECHNOLOGIES
═══════════════════════════════════════════════════════════════════════

SwiftUI              → Declarative UI framework
Swift Concurrency    → async/await for async operations
Combine              → @Published for reactive updates
Core Location        → GPS location services
MapKit               → Map display and search
UserNotifications    → Local notifications
URLSession           → API networking
Foundation           → Date, Calendar, JSON, Regex

═══════════════════════════════════════════════════════════════════════
                        DESIGN PATTERNS
═══════════════════════════════════════════════════════════════════════

MVVM                 → Model-View-ViewModel architecture
Singleton            → Services use .shared instance
Dependency Injection → Services injected into ViewModels (future)
Protocol-Oriented    → Services can be mocked for testing
Async/Await          → Modern concurrency over callbacks
ObservableObject     → State management pattern

═══════════════════════════════════════════════════════════════════════
                          ERROR HANDLING
═══════════════════════════════════════════════════════════════════════

Each service defines its own error types:

ClaudeAPIError       → API-specific errors
WeatherError         → Weather API errors
LocationError        → Location permission/availability errors
NotificationError    → Notification permission errors

All errors conform to LocalizedError for user-friendly messages.

ViewModels catch errors and update @Published errorMessage property.
Views display errors using .alert() modifier.

═══════════════════════════════════════════════════════════════════════
```
