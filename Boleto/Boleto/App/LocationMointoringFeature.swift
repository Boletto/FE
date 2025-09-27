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
        var lastEvent: LocationMonitorEvent?
        var error: LocationMonitoringError?
    }
    enum Action: Equatable {
        case checkMonitoring(SpotType)
        case startMonitoring(SpotType)
        case stopMonitoring
        case monitoringEvent(LocationMonitorEvent)
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
                    switch authorizationStatus {
                    case .notDetermined, .authorizedWhenInUse:
                        await locationClient.requestauthorziationStatus()
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
                    do {
                        // 🧪 테스트용: 5초 후 한라산 뱃지 알림
                        try await Task.sleep(for: .seconds(5))
                        await send(.monitoringEvent(.didEnterBadgeRegion(.jj01))) // 한라산 뱃지
                        
                        // 원래 코드 (테스트 후 복원용)
                        /*
                        let stream = try await locationClient.startMonitoring(spot)
                        for try await event in stream {
                            await send(.monitoringEvent(event))
                        }
                        */
                    } catch {
                        await send(.monitorFailed(.monitoringStartFailed))
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
                            try await userclient.postStickerCode(image.rawValue)
                            try await notificationClient.add(BadgeNotification(id: image.rawValue, stickerImageType: image))
                            try await alarmClient.postNewAlarm(.sticker , image.koreanString)
                        case .didEnterFrameRegion(let spotname):
                            try await notificationClient.add(FrameNotification(id: spotname))
                            try await alarmClient.postNewAlarm(.regionActive , spotname)
                        }
                    }catch {
                        await send(.monitorFailed(.notificationFailed))
                    }
                }
            case .monitorFailed(let error):
                state.error = error
                return .none
            }
            
        }
    }
}
