//
//  PastTicketDeatilFeature.swift
//  Boleto
//
//  Created by Sunho on 9/7/24.
//

import ComposableArchitecture
// PastTicketDeatilFeature.swift
@Reducer
struct PastTicketDeatilFeature {
    @Dependency(\.dismiss) var dismiss

    @ObservableState
    struct State {
        let ticket: Ticket
        var flipped = false
        var showPhotoMode: Bool = false
        let imagesString = ["beef1", "beef2", "beef3", "beef4", "logo"]
    }

    enum Action {
        case tapgobackView
        case tapTicket
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .tapgobackView:
                return .run { _ in await self.dismiss() }
            case .tapTicket:
                state.flipped.toggle()
                state.showPhotoMode.toggle()
                return .none
            }
        }
    }
}
