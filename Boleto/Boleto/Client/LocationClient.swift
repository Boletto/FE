import ComposableArchitecture
import CoreLocation
import SwiftUI

@DependencyClient
struct LocationClient {
    var authorizationStatus: @Sendable () -> CLAuthorizationStatus = {.denied}
    var requestauthorzizationStatus: @Sendable () async -> CLAuthorizationStatus = {.denied}
    var startMonitoring: @Sendable (SpotType) async throws -> AsyncStream<MonitorEvent>
    var stopMonitoring: @Sendable (SpotType) async -> Void
    
    private static var monitor: CLMonitor?
    private static var currentSpotType: SpotType?
}

enum MonitorEvent: Equatable {
    case didEnterFrameRegion
    case didEnterBadgeRegion(StickerImage)
}

extension LocationClient: DependencyKey {
    static let liveValue: Self = {
        let manager = LocationManager()
        
        return Self(
            authorizationStatus: {
                CLLocationManager().authorizationStatus
            }, requestauthorzizationStatus: {
                await withUnsafeContinuation { continuation in
                    CLLocationManager().requestWhenInUseAuthorization()
                }
            },
            startMonitoring: {spot in
                AsyncStream { continuation in
                    Task {
                        if currentSpotType == spot {
                                                continuation.finish()
                                                return
                                            }
                        currentSpotType = spot
                        let spot = spot.spot
                        monitor = await CLMonitor(spot.upperString)
               
                        let frameCondition = CLMonitor.CircularGeographicCondition(center: spot.coordinate, radius: 100.0)
                        await monitor?.add(frameCondition, identifier: "Frame")
                        for landmark in spot.landmarks {
                            let badgeCenter = CLLocationCoordinate2D(latitude: landmark.latitude, longitude: landmark.longtitude)
                            let landmarkCondition = CLMonitor.CircularGeographicCondition(center: badgeCenter, radius: 100.0)
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
            stopMonitoring: {spottype in
                let spot  = spottype.spot
                await monitor?.remove(spot.upperString)
            }
        )
    }()
    static var previewValue: Self {
            Self(
                authorizationStatus: {
                    return .authorizedAlways
                }, requestauthorzizationStatus: {
                    return .authorizedAlways
                },
                startMonitoring: { spotType in
                    return AsyncStream { continuation in
                        continuation.yield(.didEnterFrameRegion)
                        // Simulate entering a badge region after a delay
                        Task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                            continuation.yield(.didEnterBadgeRegion(.khu))
                        }
                    }
                },
                stopMonitoring: { _ in }
            )
        }
    static var testValue: Self {
        return Self(
            authorizationStatus: {
                return .authorizedAlways
            }, requestauthorzizationStatus: {
                      return .authorizedWhenInUse  // 테스트용으로 항상 권한이 허용된 상태 반환
                  },
                  startMonitoring: { spotType in
                      // 테스트용 이벤트 스트림 생성
                      return AsyncStream { continuation in
                          // 빈 스트림을 반환하여 불필요한 이벤트 발생 방지
                          continuation.finish()
                      }
                  },
                  stopMonitoring: { spotType in
                      // 아무 동작도 하지 않는 기본 구현
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


private actor LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
    }

 
}
