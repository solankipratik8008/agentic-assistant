//
//  UserIntent.swift
//  Agentic Personal Assistant
//
//  Created by Pratik Solanki on 2026-04-17.
//

import Foundation

enum UserIntent: String, Codable {
    case reminder
    case weather
    case navigation
    case general
    case unknown
}

struct DetectedIntent {
    let intent: UserIntent
    let parameters: [String: Any]
    let confidence: Double
    
    init(intent: UserIntent, parameters: [String: Any] = [:], confidence: Double = 1.0) {
        self.intent = intent
        self.parameters = parameters
        self.confidence = confidence
    }
}

// MARK: - Task Models
struct AgentTask: Identifiable {
    let id: UUID
    let intent: UserIntent
    let steps: [TaskStep]
    let status: TaskStatus
    
    init(id: UUID = UUID(), intent: UserIntent, steps: [TaskStep], status: TaskStatus = .pending) {
        self.id = id
        self.intent = intent
        self.steps = steps
        self.status = status
    }
}

struct TaskStep: Identifiable {
    let id: UUID
    let description: String
    let action: TaskAction
    var isCompleted: Bool
    
    init(id: UUID = UUID(), description: String, action: TaskAction, isCompleted: Bool = false) {
        self.id = id
        self.description = description
        self.action = action
        self.isCompleted = isCompleted
    }
}

enum TaskAction {
    case scheduleNotification(title: String, body: String, date: Date)
    case fetchWeather(location: String?)
    case openMap(query: String)
    case getLocation
    case none
}

enum TaskStatus {
    case pending
    case inProgress
    case completed
    case failed(Error)
}
