//
//  AppDeleagte.swift
//  Boleto
//
//  Created by Sunho on 9/17/24.
//

import UIKit
import BackgroundTasks
import ComposableArchitecture
class AppDelegate: UIResponder, UIApplicationDelegate {
    var app : BoletoApp?
    let store = Store(initialState: AppFeature.State()) {
          AppFeature()
      }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
      
            return true
        }

        func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
            completionHandler()
        }

        func application(_ application: UIApplication, didReceive notification: UNNotification) {
            // 알림을 받았을 때 처리할 로직
            print(notification)
            if notification.request.identifier == "LocationNotification" {
//                locationManager.handleNotificationTap()
                print("hi")
            }
        }
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "Boleto.Boleto.dailyRefresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 24 * 3600) // 24 hours from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    func handleBackgroundRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        Task{
            do {
                await store.send(.pastTravel(.fetchTickets))
//                if let 
            }
        }
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //앱이 실행되는 도중에도 알림배너표시
        completionHandler([.badge, .sound, .list])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

//        // deep link처리 시 아래 url값 가지고 처리
//        let url = response.notification.request.content.userInfo
        let userInfo =  response.notification.request.content.userInfo
        guard let userInfo = userInfo as? [String: Any] else {return}
        Task {
            await app?.handlePushNotification(data: userInfo)
        }
        completionHandler()
    }
}

