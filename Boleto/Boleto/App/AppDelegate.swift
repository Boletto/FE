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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
      
        if let currentSpot = app?.store.currentSpot {
            app?.store.send(.monitoring( .startMonitoring(currentSpot)))
        }
        
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
}
extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
//        let deviceString =  deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        let token = String(describing: fcmToken!)
//        print("Firebase registration token: \(token)")
        KeyChainManager.shared.save(key: .deviceToken, token: token)
    }
    //MARK: foreground에서 시스템 푸쉬 수신했을때 해당 메서드 호출
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //앱이 실행되는 도중에도 알림배너표시
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        completionHandler([.badge, .sound, .list, .banner])
    }
    
    //MARK: foreground, background에서 시스템 푸시를 탭하거나 dismiss했을때 해당메서드 호출
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo =  response.notification.request.content.userInfo
        guard let userInfo = userInfo as? [String: Any] else {return}
        print("Receive", userInfo)
        await app?.handlePushNotification(data: userInfo)
    }

    // 사일런트 푸쉬 메소드
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Receive", userInfo)
        guard let eventType = userInfo["eventType"] as? String else {
            completionHandler(.noData)
            return
        }
        let arriveArea = userInfo["arriveArea"] as? String
        switch eventType {
        case "SYSTEM_EVENT_STICKER_UPDATE":
            app?.checkSilentMonitoring(silentData: SilentPushModel(eventType: .fetchEventStickers))
        case "SYSTEM_EVENT_FRAME_UPDATE":
            app?.checkSilentMonitoring(silentData: SilentPushModel(eventType: .fetchEventFrames))
        case "TRAVEL_START":
            if let area = arriveArea, let spot = SpotType.fromKoreanString(area) {
                app?.checkSilentMonitoring(silentData: SilentPushModel(eventType: .startMonitoring(spot)))
            } else {
                print("Invalid or missing arriveArea for TRAVEL_START")
            }
        case "TRAVEL_STOP":
            if let area = arriveArea, let spot = SpotType.fromKoreanString(area) {
                app?.checkSilentMonitoring(silentData: SilentPushModel(eventType: .stopMonitoring(spot)))
            } else {
                print("Invalid or missing arriveArea for TRAVEL_STOP")
            }
        default:
            print("Unhandled : \(eventType)")
            
        }
        completionHandler(.newData)
    }
}

