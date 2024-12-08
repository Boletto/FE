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
        var isShowingParticipantModal = false

        init(ticket: Ticket, myID: Int) {
            self.ticket = ticket
            self.memoryFeature = MemoryFeature.State(travelId: ticket.travelID, ticketColor: ticket.color, lastEditIsMe: ticket.editableID == myID)
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case memoryFeature(MemoryFeature.Action)
        case touchnum
        case touchEditView
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


            }
        }
    }
}
