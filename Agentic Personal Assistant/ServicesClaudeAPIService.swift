//
//  ClaudeAPIService.swift
//  Agentic Personal Assistant
//
//  Created by Pratik Solanki on 2026-04-17.
//

import Foundation
import Combine

enum ClaudeAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case decodingError(Error)
    case networkError(Error)
    case missingAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return "API Error: \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .missingAPIKey:
            return "Claude API key is missing. Please add it to Configuration."
        }
    }
}

@MainActor
class ClaudeAPIService: ObservableObject {
    static let shared = ClaudeAPIService()
    
    private let baseURL = "https://api.anthropic.com/v1/messages"
    private let apiVersion = "2023-06-01"
    private let model = "claude-3-5-sonnet-20241022" // Latest Claude model
    
    // TODO: Store API key securely in Keychain in production
    // For now, we'll use a configuration file approach
    private var apiKey: String {
        // Read from Config.plist or environment
        // For development, you'll need to add your API key here
        return Configuration.claudeAPIKey
    }
    
    private init() {}
    
    func sendMessage(messages: [Message], systemPrompt: String? = nil) async throws -> String {
        print("🌐 [ClaudeAPI] sendMessage called with \(messages.count) messages")
        
        guard !apiKey.isEmpty else {
            print("❌ [ClaudeAPI] API key is missing!")
            throw ClaudeAPIError.missingAPIKey
        }
        
        guard let url = URL(string: baseURL) else {
            print("❌ [ClaudeAPI] Invalid URL")
            throw ClaudeAPIError.invalidURL
        }
        
        // Convert our Message model to Claude's format
        let claudeMessages = messages
            .filter { $0.role != .system }
            .map { ClaudeMessage(role: $0.role.rawValue, content: $0.content) }
        
        print("📤 [ClaudeAPI] Sending \(claudeMessages.count) messages to Claude")
        
        let request = ClaudeRequest(
            model: model,
            maxTokens: 1024,
            messages: claudeMessages
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        urlRequest.setValue(apiVersion, forHTTPHeaderField: "anthropic-version")
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            print("❌ [ClaudeAPI] Failed to encode request: \(error)")
            throw ClaudeAPIError.decodingError(error)
        }
        
        do {
            print("⏳ [ClaudeAPI] Waiting for response...")
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ [ClaudeAPI] Invalid response type")
                throw ClaudeAPIError.invalidResponse
            }
            
            print("📊 [ClaudeAPI] Received HTTP \(httpResponse.statusCode)")
            
            // Check for HTTP errors
            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode(ClaudeError.self, from: data) {
                    print("❌ [ClaudeAPI] API error: \(errorResponse.error.message)")
                    throw ClaudeAPIError.apiError(errorResponse.error.message)
                } else {
                    print("❌ [ClaudeAPI] HTTP error \(httpResponse.statusCode)")
                    // Try to print response body for debugging
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📄 [ClaudeAPI] Response body: \(responseString)")
                    }
                    throw ClaudeAPIError.apiError("HTTP \(httpResponse.statusCode)")
                }
            }
            
            // Decode successful response
            let decoder = JSONDecoder()
            let claudeResponse = try decoder.decode(ClaudeResponse.self, from: data)
            
            // Extract text from content array
            let responseText = claudeResponse.content
                .filter { $0.type == "text" }
                .map { $0.text }
                .joined(separator: "\n")
            
            print("✅ [ClaudeAPI] Successfully received response (\(responseText.count) characters)")
            
            return responseText
            
        } catch let error as ClaudeAPIError {
            print("❌ [ClaudeAPI] ClaudeAPIError: \(error.localizedDescription ?? "unknown")")
            throw error
        } catch {
            print("❌ [ClaudeAPI] Network error: \(error.localizedDescription)")
            throw ClaudeAPIError.networkError(error)
        }
    }
    
    // Simplified method for single message
    func chat(userMessage: String, conversationHistory: [Message] = []) async throws -> String {
        var messages = conversationHistory
        messages.append(Message(role: .user, content: userMessage))
        
        return try await sendMessage(messages: messages)
    }
}
