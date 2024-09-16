//
//  PastTravelFeature.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//
import SwiftUI
import ComposableArchitecture

@Reducer
struct PastTravelFeature {
    @ObservableState
    struct State {
        var tickets = [Ticket(departaure: "Seoul", arrival: "Busan", startDate: "2019-03-13", endDate: "2023-04-15", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답")], keywords: [.adventure]),
                       Ticket(departaure: "Jeju", arrival: "Seoul", startDate: "2024-10-2", endDate: "2025-11-2", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답")], keywords: [.fandom]),
                       Ticket(departaure: "Busan", arrival: "Jeju", startDate: "2024-10-2", endDate: "2025-11-2", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답")], keywords: [.adventure])
        ]
//        var path = StackState<PastTicketDeatilFeature.State>()
        var showingModal = false
        var modalPosition: CGPoint = .zero
        var selectedTicket: Ticket?
    }
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case tapNums(Ticket, CGPoint)
        case hideModal
        case touchTicket(Ticket)
//        case path(StackAction<PastTicketDeatilFeature.State, PastTicketDeatilFeature.Action>)
    }
    var body: some ReducerOf<Self> { 
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .tapNums(let ticket , let spot):
                state.showingModal = true
                state.modalPosition = spot
                state.selectedTicket = ticket
                return .none
            case .touchTicket(let ticket):
                return .none
//                state.path.append(PastTicketDeatilFeature.State(ticket: ticket))
//                return .none
            case .hideModal:
                state.showingModal = false
                return .none
//            case let .path(.element(id: id, action: .tapgobackView)):
//                state.path.pop(from: id)
//                return .none
//            case .path:
//                return .none
            case .binding:
                return .none
            }
            
        }
    }
}
