import ComposableArchitecture
import CoreLocation
import SwiftUI

@DependencyClient
struct LocationClient {
    var requestauthorzizationStatus: @Sendable () async -> CLAuthorizationStatus?
    var requestNotiAuthorization: () async throws-> Void
    var startMonitoring: (Spot) async throws -> AsyncStream<MonitorEvent>
    var stopMonitoring: (Spot) async -> Void
    var scheduleNotification: @Sendable (UNNotificationContent, UNNotificationTrigger) async throws -> String
    var removeAllScheduledNotifications: () async -> Void
    private static var monitoredSpots: [String: CLMonitor] = [:]
}

enum MonitorEvent: Equatable {
    case didEnterRegion(Spot)
    case didEnterBadgeRegion(StickerImage)

}

extension LocationClient: DependencyKey {
    static let liveValue: Self = {
        class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
            let locmanager = CLLocationManager()
            let notificationCenter = UNUserNotificationCenter.current()
            var authorizationStatus: CLAuthorizationStatus = .notDetermined
                 var monitors: [String: CLMonitor] = [:]
            override init() {
                super.init()
                locmanager.delegate = self
                locmanager.desiredAccuracy = kCLLocationAccuracyKilometer
                locmanager.allowsBackgroundLocationUpdates = true
                locmanager.requestAlwaysAuthorization()
            }
            func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
                        print("Location update failed: \(error.localizedDescription)")
                    }
            
            func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
                        authorizationStatus = manager.authorizationStatus
                    }
            
        }
        let manager = LocationManager()
//        let manager = CLLocationManager()
//        manager.desiredAccuracy = kCLLocationAccuracyKilometer
//        //        manager.requestAlwaysAuthorization()
//        manager.allowsBackgroundLocationUpdates = true
//        //        var montior
//        let notificationCenter = UNUserNotificationCenter.current()
        
        
        return Self(
            requestauthorzizationStatus: {
                manager.locmanager.requestAlwaysAuthorization()
                return await withCheckedContinuation { continuation in
                    DispatchQueue.main.async {
                        continuation.resume(returning: manager.authorizationStatus)
                    }
                }
            }, requestNotiAuthorization: {
                try await manager.notificationCenter.requestAuthorization(options: [.badge,.alert,.sound])
            }, startMonitoring: { spot in
                AsyncStream { continuation in
                    if Self.monitoredSpots[spot.rawValue] != nil {
                        return continuation.finish()
                    }
                    Task {
                        let monitor = await CLMonitor(spot.rawValue)
//                        let coordinate = getCoordinate(for: spot)
                        let condition = CLMonitor.CircularGeographicCondition(
                            center: spot.coordinate,
                            radius: 10 // Adjust radius as needed
                        )
                        await monitor.add(condition, identifier: spot.rawValue)
                        for landmark in spot.landmarks {
                            let landmarkCondition = CLMonitor.CircularGeographicCondition(center: CLLocationCoordinate2D(latitude: landmark.latitude, longitude: landmark.longtitude), radius: 100)
                            
                            await monitor.add(landmarkCondition, identifier: landmark.badgetype.rawValue)
                        }
                        //test용
        
//                        let test = CLMonitor.CircularGeographicCondition(center: CLLocationCoordinate2D(latitude: 37.24809168536956, longitude: 127.0422557), radius: 1)
//                        let school =  CLMonitor.CircularGeographicCondition(center: CLLocationCoordinate2D(latitude: 37.24165771476562, longitude:    127.07857), radius: 1)
////                        await
//                     
//                        await monitor.add(test, identifier: "Test")
                        
                        Self.monitoredSpots[spot.rawValue] = monitor
                        for try await event in await monitor.events {
                            switch event.state {
                            case .satisfied:
                                let content = UNMutableNotificationContent()
                                if event.identifier == spot.rawValue {
                                    content.title = "네컷 프레임을 완성해보세요"
                                    content.body = "\(event.identifier)에서 프레임을 완성해봐요"
                                    content.sound = .default
                                    content.userInfo = ["NotificationType": "fourCutframe", "Spot":"중앙도서관"]
                                    
                                       let request =   UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                                       try await manager.notificationCenter.add(request)
                                        continuation.yield(.didEnterRegion(spot))
                                } else  if let stickerImage = StickerImage(rawValue: event.identifier) {
                                    content.title = "새로운 뱃지 획득!"
                                    content.body = "\(event.identifier) 뱃지를 획득했습니다."
                                    content.sound = .default
                                    content.userInfo = ["NotificationType": "badge", "StickerImage": stickerImage.rawValue]
                                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                                                                     try await manager.notificationCenter.add(request)
                                                                     continuation.yield(.didEnterBadgeRegion(stickerImage))
                                }
                    
                            case .unknown, .unsatisfied:
                                print("나감")
                            default: break
                            }
                        }
                    }
                }
            }, stopMonitoring: {spot in
                
                if let monitor = Self.monitoredSpots[spot.rawValue] {
                    // monitor에서 모니터링 중인 조건을 제거
                    await monitor.remove(spot.rawValue)
                }
            }, scheduleNotification: { content, trigger in
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                try await manager.notificationCenter.add(request)
                return "hi"
                
                
            }, removeAllScheduledNotifications:  {
                manager.notificationCenter.removeAllPendingNotificationRequests()
                manager.notificationCenter.removeAllDeliveredNotifications()
            }
        )
    }()
}

enum LocationError: Error {
    case authorizationDenied
}

extension DependencyValues {
    var locationClient: LocationClient {
        get { self[LocationClient.self] }
        set { self[LocationClient.self] = newValue }
    }
}


