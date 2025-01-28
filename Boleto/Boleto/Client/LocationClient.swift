import ComposableArchitecture
import CoreLocation
import SwiftUI

@DependencyClient
struct LocationClient {
    var authorizationStatus: @Sendable () async -> CLAuthorizationStatus = {.denied}
    var requestauthorzizationStatus: @Sendable  () async -> Void
    var startMonitoring: @Sendable (SpotType) async throws -> AsyncStream<MonitorEvent>
    var stopMonitoring: @Sendable () async -> Void
    var disableLocationServices: @Sendable () -> Void
    var isMonitoringActive: @Sendable () async -> Bool = { false }
    
    @CasePathable
    enum MonitorEvent: Equatable {
        case didEnterFrameRegion(String)
        case didEnterBadgeRegion(StickerCodes)
    }
}



extension LocationClient: DependencyKey {
    static let liveValue: Self = {
        return Self(
            authorizationStatus: {
                 LocationActor.shared.authorizationStatus()
            }, requestauthorzizationStatus: {
                 LocationActor.shared.requestAuthorizationStatus()
            },
            startMonitoring: {spot in
              try await LocationActor.shared.startMonitoring(spot: spot)
            },
            stopMonitoring: {
                LocationActor.shared.stopMonitoring()
            }, disableLocationServices:  {
                guard let appSettingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.open(appSettingsURL)
                }
            }, isMonitoringActive: {
                LocationActor.shared.isMonitoring()
            }
        )
        @globalActor final actor LocationActor {
            static let shared = LocationActor()
            private var delegate = Delegate()
            private var monitor: CLMonitor?
            private var backgroundSession: CLBackgroundActivitySession?
            private var activeContinuation: AsyncStream<MonitorEvent>.Continuation?
            
            private final class Delegate: NSObject, @unchecked Sendable, CLLocationManagerDelegate {
                let manager = CLLocationManager()
                var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
                
                override init() {
                    super.init()
                    manager.delegate = self
                    manager.desiredAccuracy = kCLLocationAccuracyKilometer
                    manager.pausesLocationUpdatesAutomatically = false
                    manager.allowsBackgroundLocationUpdates = true
                }
                
                nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
                    guard let continuation = authorizationContinuation else { return }
                    authorizationContinuation = nil
                }
            }
            func isMonitoring() -> Bool {
                guard let monitor = monitor else {return false}
                return true
            }
            func authorizationStatus() -> CLAuthorizationStatus {
                delegate.manager.authorizationStatus
            }
            func requestAuthorizationStatus() {
                delegate.manager.requestAlwaysAuthorization()
            }
            
            func startMonitoring(spot: SpotType) async throws -> AsyncStream<MonitorEvent> {
                let stream = AsyncStream<MonitorEvent> { continuation in
                    activeContinuation = continuation
                    backgroundSession = CLBackgroundActivitySession()
                let task = Task {
                    monitor = await CLMonitor(spot.spot.upperString)
                    let frameCondition = CLMonitor.CircularGeographicCondition(
                        center: spot.spot.coordinate,
                        radius: 3000.0
                    )
                    await monitor?.add(frameCondition, identifier: "Frame")
                    for landmark in spot.spot.landmarks {
                        let badgeCenter = CLLocationCoordinate2D(
                            latitude: landmark.latitude,
                            longitude: landmark.longtitude
                        )
                        let landmarkCondition = CLMonitor.CircularGeographicCondition(
                            center: badgeCenter,
                            radius: 1000.0
                        )
                        await monitor?.add(landmarkCondition, identifier: landmark.badgetype.rawValue)
                    }
                        guard let events = await monitor?.events else {
                            continuation.finish()
                            return
                        }
                        for try await event in events {
                            switch event.state {
                            case .satisfied:
                                if event.identifier == "Frame" {
                                    await monitor?.remove("Frame")
                                    continuation.yield(.didEnterFrameRegion(spot.spot.name))
                                } else if let badgeType = StickerCodes(rawValue: event.identifier) {
                                    await monitor?.remove(event.identifier)
                                    continuation.yield(.didEnterBadgeRegion(badgeType))
                                }
                            default:
                                break
                            }
                        }
                    }
                    continuation.onTermination = { _ in
                        task.cancel()
                    }
                }
                return stream
            }
            func stopMonitoring()  {
                backgroundSession?.invalidate()
                backgroundSession = nil
                activeContinuation?.finish()
                activeContinuation = nil
                monitor = nil
            }
        }
    }()
}
extension LocationClient: TestDependencyKey {
    static let testValue = Self()
}

extension DependencyValues {
    var locationClient: LocationClient {
        get { self[LocationClient.self] }
        set { self[LocationClient.self] = newValue }
    }
}


