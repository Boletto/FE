import ComposableArchitecture
import CoreLocation
import SwiftUI

var backgroundActivitySession: CLBackgroundActivitySession?
@DependencyClient
struct LocationClient {
    var authorizationStatus: @Sendable () async -> CLAuthorizationStatus = {.denied}
    var requestauthorzizationStatus: @Sendable  () async -> Void
    var startMonitoring: @Sendable (SpotType) async throws -> AsyncStream<MonitorEvent>
    var stopMonitoring: @Sendable (SpotType) async -> Void
    var disableLocationServices: @Sendable () -> Void
     
    private static var monitor: CLMonitor?
}

enum MonitorEvent: Equatable {
    case didEnterFrameRegion
    case didEnterBadgeRegion(StickerCodes)
}

extension LocationClient: DependencyKey {
    static let liveValue: Self = {
        let locationManager = LocationManager()
        
        return Self(
            authorizationStatus: {
                return locationManager.manager.authorizationStatus
            }, requestauthorzizationStatus: {
                locationManager.manager.requestAlwaysAuthorization()
            },
            startMonitoring: {spot in
                AsyncStream { continuation in
                    @Dependency(\.notificationClient.add) var notificationClient
                    Task {
                        backgroundActivitySession = CLBackgroundActivitySession()
                        let spot = spot.spot
                        // 기존 Monitor가 존재하면 먼저 제거
                              if let existingMonitor = monitor {
//                                  existingMonitor.() // 기존 이벤트 제거
                                  monitor = nil
                              }
                        monitor = await CLMonitor(spot.upperString)
    
                        let frameCondition = CLMonitor.CircularGeographicCondition(center: spot.coordinate, radius: 3000.0)
                        monitor?.add(frameCondition, identifier: "Frame")
                        for landmark in spot.landmarks {
                            let badgeCenter = CLLocationCoordinate2D(latitude: landmark.latitude, longitude: landmark.longtitude)
                            let landmarkCondition = CLMonitor.CircularGeographicCondition(center: badgeCenter, radius: 1000.0)
                             monitor?.add(landmarkCondition, identifier: landmark.badgetype.rawValue)
                        }
                        if let events =  monitor?.events {
                            for try await event in events {
                                switch event.state {
                                case .satisfied:
                                    if event.identifier == "Frame" {
                                        monitor?.remove("Frame")
                                        continuation.yield(.didEnterFrameRegion)
                                    } else if let badgeType = StickerCodes(rawValue: event.identifier) {
                                        monitor?.remove(event.identifier)
                                        try await notificationClient(BadgeNotification(id: badgeType.rawValue, stickerImageType: badgeType))
                                        continuation.yield(.didEnterBadgeRegion(badgeType))
                                    }
                                default:
                                    break
                                }
                            }
                        }
                    }}
            },
            stopMonitoring: {spottype in
                let spot  = spottype.spot
                 monitor?.remove(spot.upperString)
                backgroundActivitySession?.invalidate()
            }, disableLocationServices:  {
                guard let appSettingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.open(appSettingsURL)
                }
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


private class LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.pausesLocationUpdatesAutomatically = false
        manager.allowsBackgroundLocationUpdates = true
    }


    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let continuation = authorizationContinuation else { return }
        authorizationContinuation = nil
        continuation.resume(returning: manager.authorizationStatus)
    }
    

}
