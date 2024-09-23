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
        var allTickets = [Ticket]()
        var ongoingTickets: [Ticket] = []
        var completedTickets: [Ticket] = []
        var futureTickets: [Ticket] = []
        var showingModal = false
        var modalPosition: CGPoint = .zero
        var selectedTicket: Ticket?
        var isLoading = false
        mutating func classifyTickets() {
            ongoingTickets = allTickets.filter { $0.status == .ongoing }
            completedTickets = allTickets.filter { $0.status == .completed }
                .sorted { $0.endDate > $1.endDate }  // 최신순 정렬
            futureTickets = allTickets.filter { $0.status == .future }
                .sorted { $0.startDate < $1.startDate }  // 가까운 미래순 정렬
        }
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
                state.allTickets = tickets
                state.classifyTickets()
                return .none
                //            case .fetchTicketsResponse(_):
                //                <#code#>
            }
            
        }
    }
}
