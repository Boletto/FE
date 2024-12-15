//
//  LocationMointoringFeature.swift
//  Boleto
//
//  Created by Sunho on 10/23/24.
//

import Foundation
import ComposableArchitecture
enum LocationMonitoringError: Error, Equatable {
    case monitoringStartFailed
    case notificationFailed
    case ticketValidationFailed
    
    var errorDescription: String? {
        switch self {
        case .monitoringStartFailed:
            return "Failed to start location monitoring"
        case .notificationFailed:
            return "Failed to schedule notification"
        case .ticketValidationFailed:
            return "Failed to validate ticket dates"
        }
    }
}
@Reducer
struct LocationMointoringFeature {
    @ObservableState
    struct State: Equatable {
        var lastEvent: MonitorEvent?
//        var currentSpot: SpotType?
        var error: LocationMonitoringError?
        @Shared(.appStorage("currentSpotType")) var currentSpot: SpotType?
        var lastCheckDate: Date?
        var currentTicket: Ticket?
    }
    enum Action: Equatable {
        case checkMonitoring(SpotType)
        case startMonitoring(SpotType)
        case stopMonitoring(SpotType)
        case moniotirngEvent(MonitorEvent)
        case notificationDelivered(String)
        case monitorFailed(LocationMonitoringError)
    }
    
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.alarmClient) var alarmClient
    @Dependency(\.userClient) var userclient
    @Dependency(\.date) var date
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .checkMonitoring(let spot):
                if let currentSpot = state.currentSpot {
                    if currentSpot != spot {
                        return .merge(
                            .send(.stopMonitoring(currentSpot)),
                            .send(.startMonitoring(spot))
                        )
                    }
                } else {
                    return .run {send in
                        await send(.startMonitoring(spot))
                    }
                }
                return .none
             
            case .startMonitoring(let spot):
                state.currentSpot = spot
                return .run {send in
                    do {
                        let stream = try await locationClient.startMonitoring(spot)
                        for try await event in stream {
                            await send(.moniotirngEvent(event))
                        }
                    } catch {
                        await send(.monitorFailed(.monitoringStartFailed))
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
                            try await alarmClient.postNewAlarm(.sticker , image.rawValue)
                            try await userclient.postStickerCode(image.rawValue)
                            await send(.notificationDelivered("Badge notification scheduled"))
                        case .didEnterFrameRegion:
                            try await notificationClient.add(FrameNotification(id: spot?.name ?? ""))
                            try await alarmClient.postNewAlarm(.regionActive , spot?.name ?? "")
                            await send(.notificationDelivered("Frame notification scheduled"))
                        }
                    }catch {
                        await send(.monitorFailed(.notificationFailed))
                    }
                }
            case .notificationDelivered:
                return .none
            case .monitorFailed(let error):
                state.error = error
//                state.isMonitoring = false
                return .none
            }
            
        }
    }
}

//extension LocationMointoringFeature {
//    static func mock(
//}
