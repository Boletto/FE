//
//  LocationManager.swift
//  Boleto
//
//  Created by Sunho on 9/14/24.
//

import Foundation
import CoreLocation
import UserNotifications
//import composableCor

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    var locationManager = CLLocationManager()
    public var monitor: CLMonitor?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var location: CLLocation?
    let gyeongbokgungLocation = CLLocation(latitude: 37.5796, longitude: 126.9770)
    let myHouse = CLLocationCoordinate2D(latitude: 37.2489089431919, longitude: 127.07499378008562)
    let school = CLLocationCoordinate2D(latitude:  37.24135596, longitude: 127.07958444)
    private let notificationCenter = UNUserNotificationCenter.current()
    
    
    private let regionRadius: CLLocationDistance = 10
    override init() {
        super.init()
        //        setupLocationManager()
        //        Task {
        //            await setmonitor()
        //        }
    }
    func setup() {
        setupLocationManager()
        requestNotificationAuthorization()
        setupMonitor()
        sendLocalNotification()
        sendDummyNotification()
    }
    private func requestNotificationAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("알림 권한이 허용되었습니다.")
            } else {
                print("알림 권한이 거부되었습니다.")
            }
        }
    }
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    private func setupMonitor() {
        Task {
            
            do {
                let updates = CLLocationUpdate.liveUpdates()
                for try await update in updates {
                    print("current\(update.location)")
                }
//                monitor =
                
                self.monitor = await CLMonitor("MyHouseMonitor")
                let myHouseCondition = CLMonitor.CircularGeographicCondition(
                    center: myHouse,
                    radius: regionRadius
                )
                let mySchool = CLMonitor.CircularGeographicCondition(center: school, radius: regionRadius)
                await monitor?.add(myHouseCondition, identifier: "MyHouse")
                await monitor?.add(mySchool, identifier: "Myschool", assuming: .unsatisfied)
                for try await event in await monitor!.events {
                    handleMonitorEvent(event)
                    print(event)
                }
            } catch {
                print("Error setting up monitor: \(error)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")

        
        // 에러 종류에 따른 추가 처리
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                print("사용자가 위치 서비스를 거부했습니다. 설정에서 권한을 확인하세요.")
            case .locationUnknown:
                print("위치를 확인할 수 없습니다. 잠시 후 다시 시도합니다.")
                // 잠시 후 위치 업데이트 재시도
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.locationManager.startUpdatingLocation()
                }
            default:
                print("알 수 없는 위치 오류가 발생했습니다.")
            }
        }
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            authorizationStatus = .authorizedWhenInUse
            locationManager.requestLocation()
            break
        case .authorizedAlways:
            authorizationStatus = .authorizedAlways
            locationManager.requestLocation()
            break
        case .notDetermined:        // Authorization not determined yet.
            authorizationStatus = .notDetermined
            
            manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }
//    func startLocationUpdates() {
//        locationManager.startUpdatingLocation()
//    }
//    func stopLocationUpdates() {
//        locationManager.stopUpdatingLocation()
//    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    private func handleMonitorEvent(_ event: CLMonitor.Event) {
        switch event.state {
        case .satisfied:
            if event.identifier == "MyHouse" {
                print("YOu enter")
                sendLocalNotification()
                //                    shouldNavigateToSpecificView = true
            } else {
                print(event.identifier)
                sendLocalNotification()
            }
        case .unsatisfied: //나갈때 호출
            print("Left the monitored region")
        @unknown default:
            break
        }
    }
    private func sendLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "집 근처에 도착했습니다!"
        content.body = "특정 뷰로 이동합니다."
        content.sound = .default
        content.userInfo = ["NotificationType": "badge"]
        let region = CLCircularRegion(center: myHouse, radius: 100, identifier: UUID().uuidString)
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request)
    }
    private func sendDummyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "앱이 켜지고 나서 5초 뒤에 열리는 테스트입니다."
        content.body = "특정 뷰로 이동합니다."
        content.sound = .default
        content.userInfo = ["NotificationType": "invitedTickets"]

        // Trigger after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // Create request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Add notification
        UNUserNotificationCenter.current().add(request)
    }
}
