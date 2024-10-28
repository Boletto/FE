//
//  LocationMointoringFeature.swift
//  Boleto
//
//  Created by Sunho on 10/23/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct LocationMointoringFeature {
    @ObservableState
    struct State: Equatable {
        var lastEvent: MonitorEvent?
        var currentSpot: SpotType?
        var error: String?
    }
    enum Action: Equatable {
        case startMonitoring(SpotType)
        case stopMonitoring(SpotType)
        case moniotirngEvent(MonitorEvent)
        case notificationDelivered(String)
        case monitorFailed(String)
    }
    
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.notificationClient) var notificationClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startMonitoring(let spot):
                state.currentSpot = spot
                return .run {send in
                    do {
                        let stream = try await locationClient.startMonitoring(spot)
                        for try await event in stream {
                            await send(.moniotirngEvent(event))
                        }
                    } catch {
                        await send(.monitorFailed(error.localizedDescription))
                    }
                }
            case .stopMonitoring(let spot):
                state.currentSpot = nil
                return .run {send in
                    await locationClient.stopMonitoring(spot)
                }
            case .moniotirngEvent(let event):
                state.lastEvent = event
                return .run {[spot = state.currentSpot?.spot] send in
                    do {
                        switch event {
                        case .didEnterBadgeRegion(let image):
                            try await notificationClient.add(BadgeNotification(id: image.rawValue, stickerImageType: image))
                            await send(.notificationDelivered("Badge notification scheduled"))
                        case .didEnterFrameRegion:
                            try await notificationClient.add(FrameNotification(id: spot?.name ?? ""))
                            await send(.notificationDelivered("Frame notification scheduled"))
                        }
                    }catch {
                        await send(.monitorFailed(error.localizedDescription))
                    }
                }
            case .notificationDelivered:
                return .none
            case .monitorFailed(let error):
                state.error = error
//                               state.isMonitoring = false
                               return .none
                
            }
            
        }
    }
}

//extension LocationMointoringFeature {
//    static func mock(
//}
