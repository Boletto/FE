//
//  UserNotificationClient.swift
//  Boleto
//
//  Created by Sunho on 9/19/24.
//

import Combine
import ComposableArchitecture
import UserNotifications

@DependencyClient
struct UserNotificationClient {
    let requestAuthorization: () async throws -> Bool
    let scheduleNotification: (UNNotificationContent, UNNotificationTrigger) async throws -> String
    let removeScheduledNotification: (String) async -> Void
    let removeAllScheduledNotifications: () async -> Void
    let getNotificationSettings: () async -> UNNotificationSettings
}
extension UserNotificationClient: DependencyKey {
    static let liveValue = UserNotificationClient(
          requestAuthorization: {
              try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
          },
          scheduleNotification: { content, trigger in
              let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
              try await UNUserNotificationCenter.current().add(request)
              return request.identifier
          },
          removeScheduledNotification: { identifier in
              await UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
          },
          removeAllScheduledNotifications: {
              await UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
          },
          getNotificationSettings: {
              await UNUserNotificationCenter.current().notificationSettings()
          }
      )
    
}
extension DependencyValues {
    var userNotifications: UserNotificationClient {
        get { self[UserNotificationClient.self] }
        set { self[UserNotificationClient.self] = newValue }
    }
}
