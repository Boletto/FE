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
    //    public enum Action: Equatable {
    //        case didChangeAuthorziation(CLAuthorizationStatus)
    //        case didEnterRegion(Spot)
    //        case didExitRegion(Spot)
    //        case didFailWithError(Error)
    //        case didStartMonitoring(region: Spot)
    //    }
    public struct Error: Swift.Error, Equatable {
        public let error: NSError
        
        public init(_ error: Swift.Error) {
            self.error = error as NSError
        }
    }
}

enum MonitorEvent: Equatable {
    case didEnterRegion(Spot)
    case didExitRegion(Spot)
}

extension LocationClient: DependencyKey {
    static let liveValue: Self = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        //        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        //        var montior
        let notificationCenter = UNUserNotificationCenter.current()
        
        
        return Self(
            requestauthorzizationStatus: {
                manager.requestAlwaysAuthorization()
                return await withCheckedContinuation { continuation in
                    DispatchQueue.main.async {
                        continuation.resume(returning: manager.authorizationStatus)
                    }
                }
            }, requestNotiAuthorization: {
                try await notificationCenter.requestAuthorization(options: [.badge,.alert,.sound])
            }, startMonitoring: { spot in
                AsyncStream {continuation in
                    if Self.monitoredSpots[spot.rawValue] != nil {
                        return
                    }
                    Task {
                        let monitor = await CLMonitor(spot.rawValue)
                        let coordinate = getCoordinate(for: spot)
                        let condition = CLMonitor.CircularGeographicCondition(
                            center: coordinate,
                            radius: 100 // Adjust radius as needed
                        )
                        await monitor.add(condition, identifier: spot.rawValue)
                        Self.monitoredSpots[spot.rawValue] = monitor
                        for try await event in await monitor.events {
                            switch event.state {
                            case .satisfied:
                                continuation.yield(.didEnterRegion(spot))
                            case .unknown, .unsatisfied:
                                continuation.yield(.didExitRegion(spot))
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
                try await notificationCenter.add(request)
                return "hi"
                
                
            }, removeAllScheduledNotifications:  {
                 notificationCenter.removeAllPendingNotificationRequests()
                notificationCenter.removeAllDeliveredNotifications()
            }
        )
    }()
    
    private static func getCoordinate(for spot: Spot) -> CLLocationCoordinate2D {
        switch spot {
        case .busan:
            return CLLocationCoordinate2D(latitude: 37.2489089431919, longitude: 127.07499378008562)
        case .seoul:
            return CLLocationCoordinate2D(latitude: 37.24135596, longitude: 127.07958444)
        case .jeju:
            return CLLocationCoordinate2D(latitude: 37.2489089431919, longitude: 127.07499378008562)
        }
    }
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

//private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
////    let continuation: AsyncStream<LocationClient.Action>.Continuation
//    var authorizationHandler: ((Bool) -> Void)?
//
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        switch manager.authorizationStatus {
//        case .authorizedWhenInUse, .authorizedAlways:
//            authorizationHandler?(true)
//        case .denied, .restricted:
//            authorizationHandler?(false)
//        default:
//            break
//        }
//    }
//}
