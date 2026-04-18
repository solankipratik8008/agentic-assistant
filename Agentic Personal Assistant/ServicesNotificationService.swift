//
//  NotificationService.swift
//  Agentic Personal Assistant
//
//  Created by Pratik Solanki on 2026-04-17.
//

import Foundation
import UserNotifications
import Combine

enum NotificationError: LocalizedError {
    case notAuthorized
    case schedulingFailed
    case invalidDate
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Notification permission not granted. Please enable notifications in Settings."
        case .schedulingFailed:
            return "Failed to schedule notification"
        case .invalidDate:
            return "Invalid notification date"
        }
    }
}

@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        Task {
            await updateAuthorizationStatus()
        }
    }
    
    func requestAuthorization() async throws -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await updateAuthorizationStatus()
            return granted
        } catch {
            throw NotificationError.notAuthorized
        }
    }
    
    func scheduleNotification(
        title: String,
        body: String,
        date: Date,
        identifier: String? = nil
    ) async throws {
        // Check authorization
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            throw NotificationError.notAuthorized
        }
        
        // Validate date is in the future
        guard date > Date() else {
            throw NotificationError.invalidDate
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Create trigger from date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create request
        let requestIdentifier = identifier ?? UUID().uuidString
        let request = UNNotificationRequest(
            identifier: requestIdentifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        do {
            try await notificationCenter.add(request)
        } catch {
            throw NotificationError.schedulingFailed
        }
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
    
    func cancelNotification(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    private func updateAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
}
