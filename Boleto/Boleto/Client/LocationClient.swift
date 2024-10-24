import ComposableArchitecture
import CoreLocation
import SwiftUI

@DependencyClient
struct LocationClient {
    var requestauthorzizationStatus: @Sendable () async -> CLAuthorizationStatus?
    var startMonitoring: (Spot) async throws -> AsyncStream<MonitorEvent>
    var stopMonitoring: (Spot) async -> Void

    private static var monitor: CLMonitor?
}

enum MonitorEvent: Equatable {
    case didEnterFrameRegion
    case didEnterBadgeRegion(StickerImage)
}

extension LocationClient: DependencyKey {
    static let liveValue: Self = {
        let manager = LocationManager()
        
        return Self(
            requestauthorzizationStatus: {
                await manager.requestAuthorization()
            },
            startMonitoring: {spot in
                AsyncStream { continuation in
                    Task {
                        monitor = await CLMonitor(spot.upperString)
                        let frameCondition = CLMonitor.CircularGeographicCondition(center: spot.coordinate, radius: 10.0)
                        await monitor?.add(frameCondition, identifier: "Frame")
                        for landmark in spot.landmarks {
                            let badgeCenter = CLLocationCoordinate2D(latitude: landmark.latitude, longitude: landmark.longtitude)
                            let landmarkCondition = CLMonitor.CircularGeographicCondition(center: badgeCenter, radius: 1.0)
                            await monitor?.add(landmarkCondition, identifier: landmark.badgetype.rawValue)
                        }
                        if let events = await monitor?.events {
                            for try await event in events {
                                switch event.state {
                                case .satisfied:
                                    if event.identifier == "Frame" {
                                        continuation.yield(.didEnterFrameRegion)
                                    } else if let badgeType = StickerImage(rawValue: event.identifier) {
                                        continuation.yield(.didEnterBadgeRegion(badgeType))
                                    }
                                default:
                                    break
                                }
                            }
                        }
                        continuation.finish()
                    }}
            },
            stopMonitoring: {spot in
                 await monitor?.remove(spot.upperString)
            }
        )
    }()
    static var  previewValue: LocationClient  {
        return Self(
            requestauthorzizationStatus: {
                .authorizedAlways
            }, startMonitoring: {spot in
                AsyncStream { continuation in
                    
                }
            }, stopMonitoring: {spot in
                
            }
        )
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


private class LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
    }
    func requestAuthorization() async -> CLAuthorizationStatus {
        manager.requestWhenInUseAuthorization()
        return await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    continuation.resume(returning: self.authorizationStatus)
                }
            }
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
