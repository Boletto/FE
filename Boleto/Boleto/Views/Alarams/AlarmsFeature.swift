//
//  AlarmsFeature.swift
//  Boleto
//
//  Created by Sunho on 9/14/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AlarmsFeature{
    @ObservableState
    struct State: Equatable {
        var alarms: [AlarmModel] = []
        var todayAlarms: [AlarmModel] = []
          var pastAlarms: [AlarmModel] = []
    }
    enum Action: Equatable {
        case tapbackbutton
        case getAllAlarm
        case updateAlarms([AlarmModel])
        case tapAlarmRow(AlarmModel)
        case alarmRowReadFailed(String)
    }
    
    @Dependency(\.alarmClient) var alarmClient
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce {state, action in
            switch action {
            case .tapbackbutton:
                return .run { _ in await self.dismiss() }
            case .getAllAlarm :
                return .run {send in
                    let alarms = try await alarmClient.getAllAlarm()
                    await send(.updateAlarms(alarms))
                }
            case .updateAlarms(let alarms):
                let (todayAlarms, pastAlarms) = alarms.reduce(into: ([AlarmModel](),[AlarmModel]())) { result, alarm in
                    if Calendar.current.isDateInToday(alarm.formattedDate) {
                        result.0.append(alarm)
                    } else {
                        result.1.append(alarm)
                    }
                }
                state.todayAlarms = todayAlarms
                state.pastAlarms = pastAlarms
                return .none
            case .tapAlarmRow(let alarmModel):
                return .run { send in
                    do {
                             try await alarmClient.putReadAlarm(alarmModel.alarmId)
                         } catch {
                             // 에러가 발생했을 때, 에러 핸들링 액션을 트리거
                             await send(.alarmRowReadFailed( error.localizedDescription))
                         }
                }
            case .alarmRowReadFailed(let err):
                print(err)
                return .none
            }
        }
    }
}
