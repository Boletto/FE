//
//  MainTravelFeatrue.swift
//  Boleto
//
//  Created by Sunho on 8/23/24.
//  

import ComposableArchitecture
import SwiftUI

@Reducer
struct DetailTravelFeature {
    @ObservableState
    struct State: Equatable{
        var ticket: Ticket
        var currentTab: Int  = 0
        var memoryFeature: MemoryFeature.State = MemoryFeature.State()
//        var path = StackState<Destination.State>()
    }
//    @Reducer(state: .equatable)
//    enum Destination {
//        case makeTicket(AddTicketFeature)
//        case notification(NotificationFeature)
//    }
    enum Action: BindableAction {
         case binding(BindingAction<State>)
        case memoryFeature(MemoryFeature.Action)
        case touchnum
        case touchEditView
//        case tapNoti
//        case path(StackActionOf<Destination>)
    }
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.memoryFeature, action: \.memoryFeature) {
            MemoryFeature()
             }

        Reduce {state, action in
            switch action {
            case .binding:
                return .none
            case .memoryFeature:
                return .none
//            case .tapNoti:
//                state.path.append(.notification(NotificationFeature.State()))
//                return .none
            case .touchnum:
                return .none
            case .touchEditView:
                return .none
            }
        }
    
    }
}
