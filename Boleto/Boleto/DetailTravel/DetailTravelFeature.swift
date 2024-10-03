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
        var memoryFeature: MemoryFeature.State
        init(ticket: Ticket) {
                  self.ticket = ticket
            self.memoryFeature = MemoryFeature.State(travelId: ticket.travelID, ticketColor: ticket.color)
              }
    }

    enum Action: BindableAction {
         case binding(BindingAction<State>)
        case memoryFeature(MemoryFeature.Action)
        case touchnum
        case touchEditView
        case updateTicket(Ticket, Bool)
        case fetchTikcket
    }
    
    @Dependency(\.travelClient) var travelClient
    
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
            case .touchnum:
                return .none
            case .touchEditView:
                return .none
            case .updateTicket(let ticket, let isLocked):
                state.ticket = ticket
                state.memoryFeature.isLocked = isLocked
                return .none
            case .fetchTikcket:
                let travelID = state.ticket.travelID
                return .run {send in
                    let (ticket, isLocked) = try await travelClient.getSingleTravel(travelID)
                    await send(.updateTicket(ticket, isLocked))
                }
            }
        }
    }
}
