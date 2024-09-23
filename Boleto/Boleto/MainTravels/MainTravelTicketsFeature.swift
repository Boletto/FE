//
//  PastTravelFeature.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//
import SwiftUI
import ComposableArchitecture

@Reducer
struct MainTravelTicketsFeature {
    @ObservableState
    struct State {
        var currentTicket: Ticket?
        var tickets = [Ticket]()
        var futureTicket: [Ticket]?
        var showingModal = false
        var modalPosition: CGPoint = .zero
        var selectedTicket: Ticket?
        var isLoading = false
    }
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case touchAddTravel
        case tapNums(Ticket, CGPoint)
        case hideModal
        case touchTicket(Ticket)
        case fetchTickets
        case updateTickets([Ticket])
//        case fetchTicketsResponse(T)
    }
    @Dependency(\.travelClient) var travelClient
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .tapNums(let ticket , let spot):
                state.showingModal = true
                state.modalPosition = spot
                state.selectedTicket = ticket
                return .none
            case .touchTicket(let _):
                return .none
            case .touchAddTravel:
                return .none
            case .hideModal:
                state.showingModal = false
                return .none
            case .binding:
                return .none
            case .fetchTickets:
                return .run { send in
                    let data = try await travelClient.getAlltravel()
                    await send(.updateTickets(data))
                }
            case .updateTickets(let tickets):
                state.tickets = tickets
                return .none
//            case .fetchTicketsResponse(_):
//                <#code#>
            }
            
        }
    }
}
