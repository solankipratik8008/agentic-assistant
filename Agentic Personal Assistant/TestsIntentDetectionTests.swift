//
//  IntentDetectionTests.swift
//  Agentic Personal AssistantTests
//
//  Created by Pratik Solanki on 2026-04-17.
//

import XCTest
@testable import Agentic_Personal_Assistant

// MARK: - Intent Detection Tests

final class IntentDetectionTests: XCTestCase {
    
    func testDetectReminderIntentBasic() async throws {
        let service = IntentDetectionService.shared
        let intent = await service.detectIntent(from: "Remind me to study at 6 PM")
        XCTAssertEqual(intent.intent, .reminder)
        XCTAssertGreaterThan(intent.confidence, 0.5)
    }
    
    func testDetectReminderIntentAlternative() async throws {
        let service = IntentDetectionService.shared
        let intent = await service.detectIntent(from: "Set a reminder to call mom")
        XCTAssertEqual(intent.intent, .reminder)
    }
    
    func testExtractReminderTask() async throws {
        let service = IntentDetectionService.shared
        let intent = await service.detectIntent(from: "Remind me to buy groceries at 5 PM")
        
        XCTAssertEqual(intent.intent, .reminder)
        if let task = intent.parameters["task"] as? String {
            XCTAssertTrue(task.contains("buy groceries"))
        }
    }
    
    func testDetectWeatherIntent() async throws {
        let service = IntentDetectionService.shared
        let intent = await service.detectIntent(from: "What's the weather today?")
        XCTAssertEqual(intent.intent, .weather)
    }
    
    func testDetectWeatherIntentWithLocation() async throws {
        let service = IntentDetectionService.shared
        let intent = await service.detectIntent(from: "What's the weather in San Francisco?")
        
        XCTAssertEqual(intent.intent, .weather)
        if let location = intent.parameters["location"] as? String {
            XCTAssertTrue(location.lowercased().contains("san francisco"))
        }
    }
    
    func testDetectNavigationIntent() async throws {
        let service = IntentDetectionService.shared
        let intent = await service.detectIntent(from: "Find parking near me")
        XCTAssertEqual(intent.intent, .navigation)
    }
    
    func testExtractMapQuery() async throws {
        let service = IntentDetectionService.shared
        let intent = await service.detectIntent(from: "Find coffee shops nearby")
        
        XCTAssertEqual(intent.intent, .navigation)
        if let query = intent.parameters["query"] as? String {
            XCTAssertTrue(query.contains("coffee"))
        }
    }
    
    func testDetectGeneralIntent() async throws {
        let service = IntentDetectionService.shared
        let intent = await service.detectIntent(from: "Tell me a joke")
        XCTAssertEqual(intent.intent, .general)
    }
    
    func testCaseInsensitiveDetection() async throws {
        let service = IntentDetectionService.shared
        let intent1 = await service.detectIntent(from: "REMIND ME TO STUDY")
        let intent2 = await service.detectIntent(from: "remind me to study")
        
        XCTAssertEqual(intent1.intent, .reminder)
        XCTAssertEqual(intent2.intent, .reminder)
    }
}

// MARK: - Message Model Tests

final class MessageModelTests: XCTestCase {
    
    func testCreateUserMessage() {
        let message = Message(role: .user, content: "Hello")
        
        XCTAssertEqual(message.role, .user)
        XCTAssertEqual(message.content, "Hello")
        XCTAssertLessThanOrEqual(message.timestamp, Date())
    }
    
    func testCreateAssistantMessage() {
        let message = Message(role: .assistant, content: "Hi there!")
        
        XCTAssertEqual(message.role, .assistant)
        XCTAssertEqual(message.content, "Hi there!")
    }
    
    func testMessagesAreIdentifiableWithUniqueIDs() {
        let message1 = Message(role: .user, content: "Test")
        let message2 = Message(role: .user, content: "Test")
        
        XCTAssertNotEqual(message1.id, message2.id)
    }
    
    func testMessagesAreEquatable() {
        let id = UUID()
        let date = Date()
        
        let message1 = Message(id: id, role: .user, content: "Test", timestamp: date)
        let message2 = Message(id: id, role: .user, content: "Test", timestamp: date)
        
        XCTAssertEqual(message1, message2)
    }
}

// MARK: - Weather Data Formatting Tests

final class WeatherDataFormattingTests: XCTestCase {
    
    func testFormatTemperatureCelsius() {
        let weather = FormattedWeather(
            location: "San Francisco",
            temperature: 20.5,
            feelsLike: 19.0,
            condition: "Clear",
            description: "Clear sky",
            humidity: 60,
            windSpeed: 3.5
        )
        
        XCTAssertEqual(weather.temperatureCelsius, "20.5°C")
    }
    
    func testFormatTemperatureFahrenheit() {
        let weather = FormattedWeather(
            location: "New York",
            temperature: 0.0,
            feelsLike: -2.0,
            condition: "Snow",
            description: "Light snow",
            humidity: 80,
            windSpeed: 5.0
        )
        
        XCTAssertEqual(weather.temperatureFahrenheit, "32.0°F")
    }
    
    func testWeatherSummaryContainsLocation() {
        let weather = FormattedWeather(
            location: "Tokyo",
            temperature: 25.0,
            feelsLike: 26.0,
            condition: "Sunny",
            description: "Clear sky",
            humidity: 55,
            windSpeed: 2.0
        )
        
        XCTAssertTrue(weather.summary.contains("Tokyo"))
    }
}

// MARK: - Example Integration Test Structure

final class ChatViewModelTests: XCTestCase {
    
    func testAddUserMessage() async throws {
        // DISABLED: Requires API mocking
        throw XCTSkip("Requires API mocking")
        
        // let viewModel = ChatViewModel()
        // let initialCount = viewModel.messages.count
        
        // This would require mocking the API
        // await viewModel.sendMessage("Hello")
        
        // XCTAssertEqual(viewModel.messages.count, initialCount + 2) // user + assistant
    }
    
    func testHandleAPIError() async throws {
        // DISABLED: Requires API mocking
        throw XCTSkip("Requires API mocking")
        
        // Test error handling
        // Mock API to return error
        // Verify errorMessage is set
    }
}

/*
 RUNNING TESTS
 =============
 
 1. In Xcode: Press Cmd+U to run all tests
 2. Or click the diamond icon next to test methods
 3. View results in Test Navigator (Cmd+6)
 
 MOCKING APIS FOR TESTS
 =====================
 
 For production testing, create mock services:
 
 ```swift
 protocol ClaudeAPIServiceProtocol {
     func sendMessage(messages: [Message]) async throws -> String
 }
 
 class MockClaudeAPIService: ClaudeAPIServiceProtocol {
     var mockResponse = "Mock response"
     var shouldThrowError = false
     
     func sendMessage(messages: [Message]) async throws -> String {
         if shouldThrowError {
             throw ClaudeAPIError.networkError(NSError())
         }
         return mockResponse
     }
 }
 ```
 
 Then inject the protocol in your ViewModel:
 
 ```swift
 class ChatViewModel: ObservableObject {
     private let claudeService: ClaudeAPIServiceProtocol
     
     init(claudeService: ClaudeAPIServiceProtocol = ClaudeAPIService.shared) {
         self.claudeService = claudeService
     }
 }
 ```
 
 XCTest FRAMEWORK
 ================
 
 XCTest is Apple's standard testing framework:
 - Test classes inherit from XCTestCase
 - Test methods start with "test" prefix
 - Use XCTAssert* functions for assertions:
   - XCTAssertEqual(a, b) - Check equality
   - XCTAssertTrue/False - Check boolean values
   - XCTAssertGreaterThan/LessThan - Compare values
   - XCTAssertNotNil - Check for non-nil values
 - Use throw XCTSkip() to skip tests
 - Supports async/await testing with async throws
 */
