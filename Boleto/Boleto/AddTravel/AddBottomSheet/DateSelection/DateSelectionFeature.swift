//
//  DateSelectionFeature.swift
//  Boleto
//
//  Created by Sunho on 9/3/24.
//

import ComposableArchitecture
import SwiftUI
@Reducer
struct DateSelectionFeature {
    @ObservableState
    struct State: Equatable {
        var month = Date()
        var startDate: Date?
        var endDate: Date?
    }
    enum Action: Equatable {
        case setMonth(Date)
        case selectDate(Date)
        case changeMonth(Int)
        case sendDate
    }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action{
            case let .setMonth(newmonth):
                state.month = newmonth
                return .none
            case let .selectDate(date):
                if state.startDate == nil || (state.startDate != nil && state.endDate != nil) {
                    state.startDate = date
                    state.endDate = nil
                } else if let start = state.startDate, date > start {
                    state.endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)
                } else {
                    state.startDate = date
                    state.endDate = nil
                }
                return .none
            case let .changeMonth(value):
                if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: state.month) {
                    state.month = newMonth
                }
                return .none
            case .sendDate:
                return .none
            }
        }
    }
}
