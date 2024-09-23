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
//        var tickets = [Ticket(departaure: "Seoul", arrival: "Busan", startDate: "2019-03-13", endDate: "2023-04-15", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답")], keywords: [.adventure]),
//                       Ticket(departaure: "Jeju", arrival: "Seoul", startDate: "2024-10-2", endDate: "2025-11-2", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답")], keywords: [.fandom]),
//                       Ticket(departaure: "Busan", arrival: "Jeju", startDate: "2024-10-2", endDate: "2025-11-2", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답")], keywords: [.adventure])
//        ]
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
                    print (data)
                 
                }
//            case .fetchTicketsResponse(_):
//                <#code#>
            }
            
        }
    }
}
