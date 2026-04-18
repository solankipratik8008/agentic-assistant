//
//  Configuration.swift
//  Agentic Personal Assistant
//
//  Created by Pratik Solanki on 2026-04-17.
//
import Foundation

/// Central configuration for API keys and app settings.
///
/// ⚠️ IMPORTANT:
/// - API keys are NOT stored in code
/// - They are injected via Xcode Environment Variables
/// - This prevents leaking secrets to GitHub
struct Configuration {
    
    // MARK: - API Keys (Secure)
    
    /// Claude API Key (set in Xcode Scheme → Environment Variables)
    static var claudeAPIKey: String {
        guard let key = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"],
              !key.isEmpty else {
            fatalError("❌ CLAUDE_API_KEY is missing. Add it in Xcode Scheme Environment Variables.")
        }
        return key
    }
    
    /// OpenWeather API Key (set in Xcode Scheme → Environment Variables)
    static var weatherAPIKey: String {
        guard let key = ProcessInfo.processInfo.environment["WEATHER_API_KEY"],
              !key.isEmpty else {
            fatalError("❌ WEATHER_API_KEY is missing. Add it in Xcode Scheme Environment Variables.")
        }
        return key
    }
    
    // MARK: - App Settings
    
    /// Maximum number of messages stored in memory
    static let maxMessageHistory = 50
    
    /// Delay for typing indicator animation
    static let typingIndicatorDelay: Double = 0.5
}
