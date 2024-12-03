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
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        completionHandler()
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
        
        let token = String(describing: fcmToken!)
        print("Firebase registration token: \(token)")
        KeyChainManager.shared.save(key: .deviceToken, token: token)
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
        let arriveArea: String = String(describing: userInfo["arriveArea"])
        let eventTpe: String = userInfo["eventType"]  as! String
        
        app?.checkSielntMonitoring(silentData: SilentPushModel(eventType: eventTpe, arriveArea: arriveArea))
        completionHandler(.newData)
    }
}

