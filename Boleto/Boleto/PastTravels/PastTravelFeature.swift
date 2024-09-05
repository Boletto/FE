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
        var tickets = [Ticket(departaure: "Seoul", arrival: "Busan", startDate: "2019-03-13", endDate: "2023-04-15", participant: 3, keywords: ["안녕"]),
                    Ticket(departaure: "Jeju", arrival: "Seoul", startDate: "2024-10-2", endDate: "2025-11-2", participant: 2, keywords: ["holy"]),
                           Ticket(departaure: "Busan", arrival: "Jeju", startDate: "2024-10-2", endDate: "2025-11-2", participant: 2, keywords: ["holy"])
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
