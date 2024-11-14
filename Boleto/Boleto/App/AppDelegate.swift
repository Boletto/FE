//
//  AppDeleagte.swift
//  Boleto
//
//  Created by Sunho on 9/17/24.
//

import UIKit
import BackgroundTasks
import ComposableArchitecture
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import os.log
class AppDelegate: UIResponder, UIApplicationDelegate {
    var app : BoletoApp?
    let store = Store(initialState: AppFeature.State()) {
          AppFeature()
      }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
 
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
               if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    print("Notification Authorization Denied")
                }
           }
        Messaging.messaging().delegate = self
        store.send(.fetchMyStickers)
        application.registerForRemoteNotifications()
            return true
        }

        func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
            completionHandler()
        }
 
//    private func application(_ application: UIApplication, didReceive notification: UNNotification) {
//            // 알림을 받았을 때 처리할 로직
//            let userInfo =  response.notification.request.content.userInfo
//            guard let userInfo = userInfo as? [String: Any] else {return}
//            Task {
//                await app?.handlePushNotification(data: userInfo)
//            }
//        }
    private func setupBackgroundTask() { //초기 설정과 최초 스케쥴링
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "Boleto.Boleto.dailyRefresh", using: nil) { task in
                   self.handleBackgroundRefresh(task: task as! BGAppRefreshTask)
               }
        scheduleNextBackgroundRefresh()
    }
    func scheduleNextBackgroundRefresh() { //다음 백그라운드 스케쥴링
        let request = BGAppRefreshTaskRequest(identifier: "Boleto.Boleto.dailyRefresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 24 * 3600) // 24 hours from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    func handleBackgroundRefresh(task: BGAppRefreshTask) {
        scheduleNextBackgroundRefresh()
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        Task{
            do {
                store.send(.allTicket(.fetchTickets))
                store.send(.backgroundRefresh)
                if store.monitoringState.isMonitoring {
                        // 이미 모니터링 중인 경우 상태 확인
                        store.send(.monitoring(.checkMonitoringStatus))
                    
                } else {
     
                }
//                if store.allTicketState.currentTicket
//                if store.
                task.setTaskCompleted(success: true)

            }
        }
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
         Messaging.messaging().apnsToken = deviceToken
        
        let deviceString =  deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNs Device Token: \(deviceString)")
        KeyChainManager.shared.save(key: .deviceToken, token: deviceString)
        print("APNs Device Token: \(deviceString)")
     }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
           
           let token = String(describing: fcmToken)
           print("Firebase registration token: \(token)")
           
           let dataDict: [String: String] = ["token": fcmToken ?? ""]
           NotificationCenter.default.post(
               name: Notification.Name("FCMToken"),
               object: nil,
               userInfo: dataDict
           )
       }
    //MARK: foreground에서 시스템 푸쉬 수신했을때 해당 메서드 호출
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //앱이 실행되는 도중에도 알림배너표시
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        completionHandler([.badge, .sound, .list])
    }
    //MARK: foreground, background에서 시스템 푸시를 탭하거나 dismiss했을때 해당메서드 호출
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo =  response.notification.request.content.userInfo
        guard let userInfo = userInfo as? [String: Any] else {return}
        print("Receive", userInfo)
//        completionHandler(.newData)
        await app?.handlePushNotification(data: userInfo)
    }

    // 사일런트 푸쉬 메소드
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Receive", userInfo)
        completionHandler(.newData)
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//
////        // deep link처리 시 아래 url값 가지고 처리
////        let url = response.notification.request.content.userInfo
//        let userInfo =  response.notification.request.content.userInfo
//        guard let userInfo = userInfo as? [String: Any] else {return}
//        Task {
//            await app?.handlePushNotification(data: userInfo)
//        }
////        if let notificationType = userInfo["NotificationType"] as? String {
////            switch notificationType {
////            case "badge":
////                if let stickerImageRawValue = userInfo["StickerImage"] as? String,
////                   let stickerImage = StickerImage(rawValue: stickerImageRawValue) {
////                    
////                }
////            case "frame":
////                break
////            default:
////                break
////            }
////        }
//        
//        completionHandler()
//    }
}

