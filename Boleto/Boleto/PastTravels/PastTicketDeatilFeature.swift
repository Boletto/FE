//
//  PastTicketDeatilFeature.swift
//  Boleto
//
//  Created by Sunho on 9/7/24.
//

import ComposableArchitecture
@Reducer
struct PastTicketDeatilFeature {
    @Dependency(\.dismiss) var dismiss
    @ObservableState
    struct State {
        let ticket: Ticket
    }
    enum Action {
        case tapgobackView
    }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .tapgobackView :
                return .none
            }
        }
    }
}
