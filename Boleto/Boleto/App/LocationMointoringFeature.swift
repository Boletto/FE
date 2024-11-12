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
        var currentSpot: SpotType?
        var error: LocationMonitoringError?
        var isMonitoring: Bool = false
        var lastCheckDate: Date?
        var currentTicket: Ticket?
    }
    enum Action: Equatable {
        case startMonitoring(SpotType)
        case stopMonitoring(SpotType)
        case moniotirngEvent(MonitorEvent)
        case notificationDelivered(String)
        case monitorFailed(LocationMonitoringError)
        case checkMonitoringStatus
    }
    
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.alarmClient) var alarmClient
    @Dependency(\.date) var date
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startMonitoring(let spot):
                state.currentSpot = spot
                state.isMonitoring = true
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
                state.isMonitoring = false
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
                state.isMonitoring = false
                return .none
            case .checkMonitoringStatus:
                let currentDate = date.now
                guard let ticket = state.currentTicket else {return .none}
                let isActiveTrip = currentDate >= ticket.startDate && currentDate <= ticket.endDate
                let isSameSpot = state.currentSpot == ticket.arrival
                return .run {[currentSpot = state.currentSpot, isMoinitoring = state.isMonitoring] send in
                    do {
                        if isActiveTrip {
                            if !isMoinitoring || !isSameSpot {
                                if let currentSpot = currentSpot {
                                    await send(.stopMonitoring(currentSpot))
                                }
                                await send(.startMonitoring(ticket.arrival))
                            }
                         
                        } else if currentDate > ticket.endDate {
                            if isMoinitoring {
                                await send(.stopMonitoring(ticket.arrival))
                            }
                        }
                     
                    }
                    catch {
                        await send(.monitorFailed(.ticketValidationFailed))
                    }
                }
            }
            
        }
    }
}

//extension LocationMointoringFeature {
//    static func mock(
//}
