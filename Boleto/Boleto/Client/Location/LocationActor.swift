import CoreLocation
import UIKit

@globalActor
final actor LocationActor {
    static let shared = LocationActor()
    private var delegate = Delegate()
    private var monitor: CLMonitor?
    private var backgroundSession: CLBackgroundActivitySession?
    private var activeContinuation: AsyncStream<LocationMonitorEvent>.Continuation?
    
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
            guard authorizationContinuation != nil else { return }
            authorizationContinuation = nil
        }
    }
    
    func isMonitoring() -> Bool {
        guard let monitor = monitor else { return false }
        return true
    }
    
    func authorizationStatus() -> CLAuthorizationStatus {
        delegate.manager.authorizationStatus
    }
    
    func requestAuthorizationStatus() {
        delegate.manager.requestAlwaysAuthorization()
    }
    
    func startMonitoring(spot: SpotType) async throws -> AsyncStream<LocationMonitorEvent> {
        let stream = AsyncStream<LocationMonitorEvent> { continuation in
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
    
    func stopMonitoring() {
        backgroundSession?.invalidate()
        backgroundSession = nil
        activeContinuation?.finish()
        activeContinuation = nil
        monitor = nil
    }
} 
