//
//  ChatViewModel.swift
//  Agentic Personal Assistant
//
//  Created by Pratik Solanki on 2026-04-17.
//

import Foundation
import SwiftUI
import MapKit
import Combine
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showMapSheet = false
    @Published var mapQuery: String = ""
    
    private let claudeService = ClaudeAPIService.shared
    private let weatherService = WeatherService.shared
    private let locationService = LocationService.shared
    private let notificationService = NotificationService.shared
    private let intentService = IntentDetectionService.shared
    
    init() {
        // Add welcome message
        let welcomeMessage = Message(
            role: .assistant,
            content: """
            👋 Hello! I'm your AI assistant. I can help you with:
            
            • Setting reminders
            • Checking the weather
            • Finding places on the map
            • General questions
            
            Just ask me anything!
            """
        )
        messages.append(welcomeMessage)
    }
    
    // MARK: - Public Methods
    
    func sendMessage(_ content: String) async {
        print("📤 [ChatViewModel] sendMessage called with: \"\(content)\"")
        
        guard !content.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("⚠️ [ChatViewModel] Empty message, ignoring")
            return
        }
        
        // Add user message
        let userMessage = Message(role: .user, content: content)
        messages.append(userMessage)
        print("✅ [ChatViewModel] User message added. Total messages: \(messages.count)")
        
        // Clear error
        errorMessage = nil
        isLoading = true
        
        do {
            // Detect intent
            print("🔍 [ChatViewModel] Detecting intent...")
            let intent = intentService.detectIntent(from: content)
            print("🎯 [ChatViewModel] Detected intent: \(intent.intent.rawValue) (confidence: \(intent.confidence))")
            
            // Execute based on intent
            switch intent.intent {
            case .reminder:
                print("⏰ [ChatViewModel] Handling reminder intent")
                await handleReminderIntent(content: content, parameters: intent.parameters)
            case .weather:
                print("🌤️ [ChatViewModel] Handling weather intent")
                await handleWeatherIntent(content: content, parameters: intent.parameters)
            case .navigation:
                print("🗺️ [ChatViewModel] Handling navigation intent")
                await handleNavigationIntent(content: content, parameters: intent.parameters)
            case .general, .unknown:
                print("💬 [ChatViewModel] Handling general chat")
                await handleGeneralChat(content: content)
            }
            
            print("✅ [ChatViewModel] Intent handling completed")
            
        } catch {
            print("❌ [ChatViewModel] Error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            addAssistantMessage("Sorry, I encountered an error: \(error.localizedDescription)")
        }
        
        isLoading = false
        print("🏁 [ChatViewModel] sendMessage completed. Total messages: \(messages.count)")
    }
    
    func clearChat() {
        messages.removeAll()
    }
    
    // MARK: - Intent Handlers
    
    private func handleReminderIntent(content: String, parameters: [String: Any]) async {
        // Check notification permission
        if notificationService.authorizationStatus != .authorized {
            do {
                let granted = try await notificationService.requestAuthorization()
                if !granted {
                    addAssistantMessage("I need notification permission to set reminders. Please enable it in Settings.")
                    return
                }
            } catch {
                addAssistantMessage("Failed to request notification permission: \(error.localizedDescription)")
                return
            }
        }
        
        // Extract parameters
        guard let task = parameters["task"] as? String,
              let date = parameters["date"] as? Date else {
            // Ask Claude to extract the information
            let prompt = """
            The user wants to set a reminder. Extract:
            1. The task/reminder text
            2. The time (provide it in a clear format)
            
            User message: "\(content)"
            
            If the time is unclear or missing, ask the user to specify when they want to be reminded.
            """
            
            do {
                let response = try await claudeService.chat(userMessage: prompt)
                addAssistantMessage(response)
            } catch {
                addAssistantMessage("I couldn't understand the reminder details. Please try again with format: 'Remind me to [task] at [time]'")
            }
            return
        }
        
        // Schedule notification
        do {
            try await notificationService.scheduleNotification(
                title: "Reminder",
                body: task,
                date: date
            )
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            
            addAssistantMessage("✅ Reminder set! I'll notify you to \"\(task)\" on \(formatter.string(from: date)).")
        } catch {
            addAssistantMessage("Failed to set reminder: \(error.localizedDescription)")
        }
    }
    
    private func handleWeatherIntent(content: String, parameters: [String: Any]) async {
        do {
            var weather: FormattedWeather
            
            if let location = parameters["location"] as? String {
                // Use specified location
                weather = try await weatherService.fetchWeather(for: location)
            } else {
                // Use current location
                // Check location permission
                if locationService.authorizationStatus == .notDetermined {
                    locationService.requestAuthorization()
                    addAssistantMessage("I need your location permission to check the weather. Please grant access and try again.")
                    return
                }
                
                guard locationService.authorizationStatus == .authorizedWhenInUse ||
                      locationService.authorizationStatus == .authorizedAlways else {
                    addAssistantMessage("Location permission is required to check weather. Please enable it in Settings, or specify a city name.")
                    return
                }
                
                let location = try await locationService.getCurrentLocation()
                weather = try await weatherService.fetchWeather(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
            
            addAssistantMessage(weather.summary)
            
        } catch {
            addAssistantMessage("Failed to fetch weather: \(error.localizedDescription)")
        }
    }
    
    private func handleNavigationIntent(content: String, parameters: [String: Any]) async {
        guard let query = parameters["query"] as? String else {
            addAssistantMessage("What would you like to find on the map?")
            return
        }
        
        // Open map sheet
        mapQuery = query
        showMapSheet = true
        
        addAssistantMessage("🗺️ Opening map to search for: \(query)")
    }
    
    private func handleGeneralChat(content: String) async {
        print("💬 [handleGeneralChat] Starting general chat handler")
        
        do {
            // Get conversation history (last 10 messages for context)
            let recentMessages = Array(messages.suffix(10))
            print("📝 [handleGeneralChat] Using \(recentMessages.count) recent messages for context")
            
            // Add system prompt for agent behavior
            let systemPrompt = """
            You are a helpful AI assistant integrated into an iOS app. You can:
            - Set reminders and notifications
            - Check weather information
            - Help with navigation and finding places
            - Answer general questions
            
            Be concise, friendly, and helpful. When users ask about capabilities you have, 
            explain what you can do. Use emojis sparingly to make responses friendly.
            """
            
            var messagesToSend = recentMessages
            // Note: Claude API doesn't support system messages in the messages array
            // Instead, we'll prepend context to the first message if needed
            
            print("🌐 [handleGeneralChat] Calling Claude API...")
            let response = try await claudeService.sendMessage(messages: messagesToSend)
            print("✅ [handleGeneralChat] Received response from Claude: \"\(response.prefix(50))...\"")
            
            addAssistantMessage(response)
            
        } catch {
            print("❌ [handleGeneralChat] Error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            
            // Fallback response if API fails
            let fallbackMessage = """
            I'm having trouble connecting to my AI service right now. However, I can still help you with:
            
            • Setting reminders (try: "remind me to...")
            • Checking weather (try: "what's the weather?")
            • Finding places (try: "find coffee near me")
            
            Please try one of these, or try your question again in a moment!
            """
            
            addAssistantMessage(fallbackMessage)
        }
    }
    
    // MARK: - Helper Methods
    
    private func addAssistantMessage(_ content: String) {
        let message = Message(role: .assistant, content: content)
        messages.append(message)
    }
}
