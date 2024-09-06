//
//  PastTravelFeature.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//

import ComposableArchitecture

@Reducer
struct PastTravelFeature {
    @ObservableState
    struct State {
        var tickets = [Ticket(departaure: "Seoul", arrival: "Busan", startDate: "2019-03-13", endDate: "2023-04-15", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답")], keywords: [.adventure]),
                       Ticket(departaure: "Jeju", arrival: "Seoul", startDate: "2024-10-2", endDate: "2025-11-2", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답")], keywords: [.fandom]),
                       Ticket(departaure: "Busan", arrival: "Jeju", startDate: "2024-10-2", endDate: "2025-11-2", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답")], keywords: [.heritageSite])
        ]
    }
    enum Action {
        case touchTicket(Int)
    }
    var body: some ReducerOf<Self> { 
        Reduce { state, action in
            switch action {
            case .touchTicket(let index):
                return .none
            }
            
        }
    }
}
