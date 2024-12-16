//
//  AlarmClient.swift
//  Boleto
//
//  Created by Sunho on 11/11/24.
//

import Foundation
import ComposableArchitecture

@DependencyClient
struct AlarmClient {
    var postNewAlarm: @Sendable (AlarmType, String) async throws -> Void
    var getAllAlarm: @Sendable () async throws -> [AlarmModel]
    var putReadAlarm: @Sendable (Int) async throws -> Void
}
extension AlarmClient: DependencyKey {
    static var liveValue: AlarmClient = {
        return Self(
            postNewAlarm: { type, value in
                let data = try await NetworkManager.request(endpoint: AlarmRouter.postAlarm(AlarmRequest(alarmType: type, value: value)), responseType: EmptyData.self)
                
            }, getAllAlarm: {
                let data = try await NetworkManager.request(endpoint: AlarmRouter.getAlarm, responseType: [AlarmResponse].self)
                return data.map{$0.toAlarm()}
            }, putReadAlarm: { alarmId in
                let data = try await NetworkManager.request(endpoint: AlarmRouter.putAlarm(alarmId), responseType: EmptyData.self)
            }
        )
    }()
}
extension AlarmClient {
    static var testValue: AlarmClient = {
        return Self(
            postNewAlarm: { type, _ in
            }, getAllAlarm: {
                return AlarmModel.dummy
            }, putReadAlarm: { _ in
                
            }
        )
    }()
}
extension DependencyValues {
    var alarmClient: AlarmClient {
        get { self[AlarmClient.self]}
        set { self[AlarmClient.self] = newValue}
    }
}
