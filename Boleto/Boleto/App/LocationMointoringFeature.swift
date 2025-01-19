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
        var lastEvent: LocationClient.MonitorEvent?
        var error: LocationMonitoringError?
    }
    enum Action: Equatable {
        case checkMonitoring(SpotType)
        case startMonitoring(SpotType)
        case stopMonitoring
        case monitoringEvent(LocationClient.MonitorEvent)
        case notificationDelivered(String)
        case monitorFailed(LocationMonitoringError)
    }
    
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.alarmClient) var alarmClient
    @Dependency(\.userClient) var userclient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .checkMonitoring(let spot):
                return .run { send in
                    let isMonitoring = await locationClient.isMonitoringActive()
                    if isMonitoring {
                        return
                    }
           
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
                
            case .startMonitoring(let spot):
                return .run { send in
                    let stream = try await locationClient.startMonitoring(spot)
                    for try await event in stream {
                        await send(.monitoringEvent(event))
                    }
                }
            case .stopMonitoring:
                return .run {send in
                    await locationClient.stopMonitoring()
                }
            case .monitoringEvent(let event):
                state.lastEvent = event
                return .run { send in
                    do {
                        switch event {
                        case .didEnterBadgeRegion(let image):
                            try await notificationClient.add(BadgeNotification(id: image.rawValue, stickerImageType: image))
                            try await alarmClient.postNewAlarm(.sticker , image.koreanString)
                            try await userclient.postStickerCode(image.rawValue)
                            await send(.notificationDelivered("Badge notification scheduled"))
                        case .didEnterFrameRegion(let spotname):
                            try await notificationClient.add(FrameNotification(id: spotname))
                            try await alarmClient.postNewAlarm(.regionActive , spotname)
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
