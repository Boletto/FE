import ComposableArchitecture
import CoreLocation
import SwiftUI

@DependencyClient
struct LocationClient {
    var authorizationStatus: @Sendable () -> CLAuthorizationStatus = {.denied}
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
                    Task {
                        let spot = spot.spot
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
            }, disableLocationServices:  {
                guard let appSettingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.open(appSettingsURL)
                }
            }
        )
    }()
//    static var previewValue: Self {
//        Self(
//            authorizationStatus: {
//                return .authorizedAlways
//            }, requestauthorzizationStatus: {
//                return .authorizedAlways
//            },
//            startMonitoring: { spotType in
//                return AsyncStream { continuation in
//                    continuation.yield(.didEnterFrameRegion)
//                    // Simulate entering a badge region after a delay
//                    Task {
//                        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
//                        continuation.yield(.didEnterBadgeRegion(.khu))
//                    }
//                }
//            },
//            stopMonitoring: { _ in }
//        )
//    }
//    static var testValue: Self {
//        return Self(
//            authorizationStatus: {
//                return .authorizedAlways
//            }, requestauthorzizationStatus: {
//                return .authorizedWhenInUse  // 테스트용으로 항상 권한이 허용된 상태 반환
//            },
//            startMonitoring: { spotType in
//                // 테스트용 이벤트 스트림 생성
//                return AsyncStream { continuation in
//
//                    continuation.yield(.didEnterBadgeRegion(.khu))
//                    continuation.finish()
//                }
//            },
//            stopMonitoring: { spotType in
//                // 아무 동작도 하지 않는 기본 구현
//            }
//        )
//    }
    
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
        manager.allowsBackgroundLocationUpdates = true
    }
    func requestAuthorization() async -> CLAuthorizationStatus {
        await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    // CLLocationManagerDelegate 메서드
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let continuation = authorizationContinuation else { return }
        authorizationContinuation = nil
        continuation.resume(returning: manager.authorizationStatus)
    }

}
