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
    var postNewAlarm: @Sendable (AlarmType, String) async throws -> Bool
    var getAllAlarm: @Sendable () async throws -> [AlarmModel]
    var putReadAlarm: @Sendable (Int) async throws -> Void
}
extension AlarmClient: DependencyKey {
    static var liveValue: AlarmClient = {
        return Self(
            postNewAlarm: { type, value in
                let task = API.session.request(AlarmRouter.postAlarm(AlarmRequest(alarmType: type, value: value)), interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<EmptyData>.self)
                return try await task.value.success
            }, getAllAlarm: {
                let task = API.session.request(AlarmRouter.getAlarm, interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<[AlarmResponse]>.self)
                switch await task.result{
                case .success(let data):
                    guard let data = data.data else {return []}
                    return data.map{$0.toAlarm()}
                case .failure(let err):
                    throw err
                }
            }, putReadAlarm: { alarmId in
                let task = API.session.request(AlarmRouter.putAlarm(alarmId), interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<EmptyData>.self)
                switch await task.result {
                  case .success:
                      // 성공했을 경우, 아무 작업도 하지 않고 그냥 반환
                      return
                  case .failure(let error):
                      // 실패했을 경우 에러를 던짐
                      throw error
                  }
                
            }
            )
    }()
}
extension AlarmClient {
    static var testValue: AlarmClient = {
        return Self(
            postNewAlarm: { type, _ in
                return true
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
