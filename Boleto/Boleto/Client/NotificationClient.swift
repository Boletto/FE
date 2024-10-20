//
//  NotificationClient.swift
//  Boleto
//
//  Created by Sunho on 10/16/24.
//

import Foundation
import UserNotifications
import ComposableArchitecture

@DependencyClient
struct NotificationClient {
    var add: (NotificationProtocol) async throws -> Void
    var removeAllPendingNotifications: () -> Void
    var requestAuthorication: (UNAuthorizationOptions) async throws -> Bool
}
extension NotificationClient: DependencyKey {
    static let liveValue: Self = {
        return Self(
            add: { notification in
                let content = UNMutableNotificationContent()
                content.title = notification.title
                content.body = notification.body
                content.sound = .default
                content.userInfo = notification.toUserInfo()
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
                let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
                try await UNUserNotificationCenter.current().add(request)
                
            }, removeAllPendingNotifications: {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            }, requestAuthorication: {
                try await UNUserNotificationCenter.current().requestAuthorization(options: $0)
            }
        )
    }()
}
