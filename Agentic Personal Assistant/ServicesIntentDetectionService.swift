//
//  IntentDetectionService.swift
//  Agentic Personal Assistant
//
//  Created by Pratik Solanki on 2026-04-17.
//

import Foundation

@MainActor
class IntentDetectionService {
    static let shared = IntentDetectionService()
    
    private init() {}
    
    func detectIntent(from message: String) -> DetectedIntent {
        let lowercased = message.lowercased()
        
        // Reminder detection
        if containsReminderKeywords(lowercased) {
            if let reminderParams = extractReminderParameters(from: message) {
                return DetectedIntent(intent: .reminder, parameters: reminderParams, confidence: 0.9)
            }
            return DetectedIntent(intent: .reminder, confidence: 0.7)
        }
        
        // Weather detection
        if containsWeatherKeywords(lowercased) {
            var params: [String: Any] = [:]
            if let location = extractLocation(from: message) {
                params["location"] = location
            }
            return DetectedIntent(intent: .weather, parameters: params, confidence: 0.9)
        }
        
        // Navigation/Map detection
        if containsNavigationKeywords(lowercased) {
            var params: [String: Any] = [:]
            if let query = extractMapQuery(from: message) {
                params["query"] = query
            }
            return DetectedIntent(intent: .navigation, parameters: params, confidence: 0.85)
        }
        
        // Default to general conversation
        return DetectedIntent(intent: .general, confidence: 1.0)
    }
    
    // MARK: - Reminder Detection
    
    private func containsReminderKeywords(_ text: String) -> Bool {
        let keywords = ["remind", "reminder", "schedule", "notify", "notification", "alert"]
        return keywords.contains(where: { text.contains($0) })
    }
    
    private func extractReminderParameters(from message: String) -> [String: Any]? {
        var params: [String: Any] = [:]
        
        // Extract task/title
        if let task = extractReminderTask(from: message) {
            params["task"] = task
        }
        
        // Extract time
        if let date = extractDateTime(from: message) {
            params["date"] = date
        }
        
        return params.isEmpty ? nil : params
    }
    
    private func extractReminderTask(from message: String) -> String? {
        // Pattern: "remind me to [TASK]"
        let patterns = [
            "remind me to (.+?)(?:at|on|in|$)",
            "reminder to (.+?)(?:at|on|in|$)",
            "remind me (.+?)(?:at|on|in|$)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)),
               let range = Range(match.range(at: 1), in: message) {
                return String(message[range]).trimmingCharacters(in: .whitespaces)
            }
        }
        
        return nil
    }
    
    private func extractDateTime(from message: String) -> Date? {
        let lowercased = message.lowercased()
        let calendar = Calendar.current
        let now = Date()
        
        // Time patterns (e.g., "6 PM", "18:00", "6:30 PM")
        if let timeMatch = extractTime(from: lowercased) {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = timeMatch.hour
            components.minute = timeMatch.minute
            
            if var date = calendar.date(from: components) {
                // If time has passed today, schedule for tomorrow
                if date < now {
                    date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
                }
                return date
            }
        }
        
        // Relative times
        if lowercased.contains("in") {
            if let minutes = extractMinutes(from: lowercased) {
                return calendar.date(byAdding: .minute, value: minutes, to: now)
            }
            if let hours = extractHours(from: lowercased) {
                return calendar.date(byAdding: .hour, value: hours, to: now)
            }
        }
        
        return nil
    }
    
    private func extractTime(from text: String) -> (hour: Int, minute: Int)? {
        // Pattern for "6 PM", "6:30 PM", "18:00"
        let patterns = [
            "(\\d{1,2}):(\\d{2})\\s*(am|pm)",
            "(\\d{1,2})\\s*(am|pm)",
            "(\\d{1,2}):(\\d{2})"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                
                let nsString = text as NSString
                var hour = Int(nsString.substring(with: match.range(at: 1))) ?? 0
                var minute = 0
                
                if match.numberOfRanges > 2 {
                    let secondCapture = nsString.substring(with: match.range(at: 2))
                    
                    // Check if second capture is minutes or am/pm
                    if let mins = Int(secondCapture) {
                        minute = mins
                        // Check for am/pm in third capture
                        if match.numberOfRanges > 3 {
                            let meridiem = nsString.substring(with: match.range(at: 3))
                            if meridiem.lowercased() == "pm" && hour < 12 {
                                hour += 12
                            } else if meridiem.lowercased() == "am" && hour == 12 {
                                hour = 0
                            }
                        }
                    } else if secondCapture.lowercased() == "pm" && hour < 12 {
                        hour += 12
                    } else if secondCapture.lowercased() == "am" && hour == 12 {
                        hour = 0
                    }
                }
                
                return (hour: hour, minute: minute)
            }
        }
        
        return nil
    }
    
    private func extractMinutes(from text: String) -> Int? {
        if let regex = try? NSRegularExpression(pattern: "in (\\d+) minutes?", options: .caseInsensitive),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
            let nsString = text as NSString
            return Int(nsString.substring(with: match.range(at: 1)))
        }
        return nil
    }
    
    private func extractHours(from text: String) -> Int? {
        if let regex = try? NSRegularExpression(pattern: "in (\\d+) hours?", options: .caseInsensitive),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
            let nsString = text as NSString
            return Int(nsString.substring(with: match.range(at: 1)))
        }
        return nil
    }
    
    // MARK: - Weather Detection
    
    private func containsWeatherKeywords(_ text: String) -> Bool {
        let keywords = ["weather", "temperature", "forecast", "rain", "sunny", "cloudy", "hot", "cold"]
        return keywords.contains(where: { text.contains($0) })
    }
    
    private func extractLocation(from message: String) -> String? {
        // Pattern: "weather in [LOCATION]"
        let patterns = [
            "weather in ([a-zA-Z\\s]+)",
            "weather at ([a-zA-Z\\s]+)",
            "weather for ([a-zA-Z\\s]+)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)),
               let range = Range(match.range(at: 1), in: message) {
                return String(message[range]).trimmingCharacters(in: .whitespaces)
            }
        }
        
        return nil
    }
    
    // MARK: - Navigation Detection
    
    private func containsNavigationKeywords(_ text: String) -> Bool {
        let keywords = ["map", "navigate", "direction", "find", "locate", "parking", "restaurant", "coffee", "nearby"]
        return keywords.contains(where: { text.contains($0) })
    }
    
    private func extractMapQuery(from message: String) -> String? {
        // Pattern: "find [QUERY]"
        let patterns = [
            "find (.+?)(?:near|in|$)",
            "locate (.+?)(?:near|in|$)",
            "show me (.+?)(?:near|in|$)",
            "parking near (.+)",
            "(.+?) near me"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)),
               let range = Range(match.range(at: 1), in: message) {
                return String(message[range]).trimmingCharacters(in: .whitespaces)
            }
        }
        
        return nil
    }
}
