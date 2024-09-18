//
//  PastTicketDeatilFeature.swift
//  Boleto
//
//  Created by Sunho on 9/7/24.
//

import ComposableArchitecture
import SwiftUI
// PastTicketDeatilFeature.swift
@Reducer
struct PastTicketDeatilFeature {
    @Dependency(\.dismiss) var dismiss

    @ObservableState
    struct State {
        let ticket: Ticket
        var flipped = false
        var showPhotoMode: Bool = false
        var showingModal = false
        var modalPosition: CGPoint = .zero
        let imagesString = ["beef1", "beef2", "beef3", "beef4", "logo"]
    }

    enum Action {
        case tapNums(CGPoint)
        case tapgobackView
        case tapTicket
        case hideticket
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
            case .tapNums(let point):
                state.showingModal = true
                state.modalPosition = point
                return .none
            case .hideticket:
                state.showingModal = false
                
                return .none
            }
        }
    }
}
