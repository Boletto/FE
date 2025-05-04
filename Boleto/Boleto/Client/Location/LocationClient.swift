import ComposableArchitecture
import CoreLocation
import SwiftUI
@CasePathable
enum LocationMonitorEvent: Equatable {
    case didEnterFrameRegion(String)
    case didEnterBadgeRegion(StickerCodes)
}

@DependencyClient
struct LocationClient {
    var authorizationStatus: @Sendable () async -> CLAuthorizationStatus = { .denied }
    var requestauthorziationStatus: @Sendable () async -> Void
    var startMonitoring: @Sendable (SpotType) async throws -> AsyncStream<LocationMonitorEvent>
    var stopMonitoring: @Sendable () async -> Void
    var disableLocationServices: @Sendable () -> Void
    var isMonitoringActive: @Sendable () async -> Bool = { false }
    

}

extension LocationClient: DependencyKey {
    static let liveValue = Self(
        authorizationStatus: { LocationActor.shared.authorizationStatus() },
        requestauthorziationStatus: { LocationActor.shared.requestAuthorizationStatus() },
        startMonitoring: { spot in try await LocationActor.shared.startMonitoring(spot: spot) },
        stopMonitoring: { LocationActor.shared.stopMonitoring() },
        disableLocationServices: {
            guard let appSettingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            DispatchQueue.main.async {
                UIApplication.shared.open(appSettingsURL)
            }
        },
        isMonitoringActive: { LocationActor.shared.isMonitoring() }
    )
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


