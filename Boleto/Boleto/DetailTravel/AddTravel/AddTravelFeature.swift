//
//  AddTravelFeature.swift
//  Boleto
//
//  Created by Sunho on 8/31/24.
import ComposableArchitecture
import SwiftUI

@Reducer
struct AddTravelFeature {
//    @Reducer(state: .equatable)
//    enum Destination {
//        case makeTicket(AddTicketFeature)
//    }
    
    @ObservableState
    struct State: Equatable {
        var addticketFeature: AddTicketFeature.State = .init()
//        var path = StackState<Destination.State>()
    }
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case gotoAddTicket
        case addTicketFeature(AddTicketFeature.Action)
//        case path(StackAction<Destination.State, Destination.Action>)
    }
    var body: some ReducerOf<Self> {
        BindingReducer()
//        Scope(state: \.addTicketFeature, action: \.addTicketFeature) {
//            AddTicketFeature()
//        }
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
//            case .path(.popFrom(id: _)):
//                state.path.removeAll()
//                return .none
            case .gotoAddTicket:
   
                return .none
            case .addTicketFeature:
                return .none
            }
        }
    }
}
