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
    var authorizationStatus: @Sendable () async -> UNAuthorizationStatus = {.denied}
    var add:  @Sendable (NotificationProtocol) async throws -> Void
    var removeAllPendingNotifications: () -> Void
    var requestAuthorication: (UNAuthorizationOptions) async throws -> Bool
    
}
extension NotificationClient: DependencyKey {
    static let liveValue: Self = {
        return Self(
            authorizationStatus: {
                await withCheckedContinuation { continuation in
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        continuation.resume(returning: settings.authorizationStatus)
                    }
                }
            }, add: { notification in
                let content = UNMutableNotificationContent()
                content.title = notification.title
                content.body = notification.body
                content.sound = .default
                content.userInfo = notification.toUserInfo()
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
                try await UNUserNotificationCenter.current().add(request)
                
            }, removeAllPendingNotifications: {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            }, requestAuthorication: {
                try await UNUserNotificationCenter.current().requestAuthorization(options: $0)
            }
        )
    }()
    static let testValue: Self = Self(
        authorizationStatus: {
            .authorized
        }, add: { _ in },  // 테스트에서는 실제로 알림을 보내지 않음
         removeAllPendingNotifications: { },
         requestAuthorication: { _ in true }  // 테스트에서는 항상 승인됨
     )
}

extension DependencyValues {
    var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}
