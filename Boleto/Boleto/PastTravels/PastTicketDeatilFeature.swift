//
//  PastTicketDeatilFeature.swift
//  Boleto
//
//  Created by Sunho on 9/7/24.
//

import ComposableArchitecture
@Reducer
struct PastTicketDeatilFeature {
    @ObservableState
    struct State {
        let ticket: Ticket
    }
    enum Action {
        
    }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            }
        }
    }
}
