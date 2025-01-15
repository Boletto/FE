//
//  LocationMointoringFeature.swift
//  Boleto
//
//  Created by Sunho on 10/23/24.
//

import Foundation
import ComposableArchitecture
import UIKit
enum LocationMonitoringError: Error, Equatable {
    case monitoringStartFailed
    case notificationFailed
    case ticketValidationFailed
    case authorizedFailed
    
    var errorDescription: String? {
        switch self {
        case .monitoringStartFailed:
            return "Failed to start location monitoring"
        case .notificationFailed:
            return "Failed to schedule notification"
        case .ticketValidationFailed:
            return "Failed to validate ticket dates"
        case .authorizedFailed:
            return "Failed to access location"
        }
    }
}
@Reducer
struct LocationMointoringFeature {
    @ObservableState
    struct State: Equatable {
        var lastEvent: MonitorEvent?
        var error: LocationMonitoringError?
        var currentSpot: SpotType?
    }
    enum Action: Equatable {
        case checkMonitoring(SpotType)
        case startMonitoring(SpotType)
        case stopMonitoring
        case monitoringEvent(MonitorEvent)
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
                return .run {[current = state.currentSpot] send in
                    if let currentSpot = current {
                        if  currentSpot != spot {
                            await send(.stopMonitoring)
                        } else {
                            return
                        }
                  
                    } else {
                        let authorizationStatus = await locationClient.authorizationStatus()
                        // 새로운 Spot 모니터링 및 권한 요청
                        switch authorizationStatus {
                        case .notDetermined, .authorizedWhenInUse:
                            // 권한 요청
                            await locationClient.requestauthorzizationStatus()
                            await send(.startMonitoring(spot))
                            
                        case .denied, .restricted:
                            locationClient.disableLocationServices()
                        case .authorizedAlways:
                            await send(.startMonitoring(spot))
                        @unknown default:
                            await send(.monitorFailed(.monitoringStartFailed))
                        }
                    }
                }
                
            case .startMonitoring(let spot):
                state.currentSpot = spot
                return .run { send in
                    let stream = try await locationClient.startMonitoring(spot)
                    for try await event in stream {
                        await send(.monitoringEvent(event))
                    }
                }
            case .stopMonitoring:
                state.currentSpot = nil
                return .run {send in
                    await locationClient.stopMonitoring()
                }
            case .monitoringEvent(let event):
                state.lastEvent = event
                return .run {[spot = state.currentSpot?.spot] send in
                    do {
                        switch event {
                        case .didEnterBadgeRegion(let image):
                            try await notificationClient.add(BadgeNotification(id: image.rawValue, stickerImageType: image))
                            try await alarmClient.postNewAlarm(.sticker , image.koreanString)
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
                return .none
            }
            
        }
    }
}

//extension LocationMointoringFeature {
//    static func mock(
//}
