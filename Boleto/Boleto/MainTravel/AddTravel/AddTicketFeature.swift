//
//  AddTicketFeature.swift
//  Boleto
//
//  Created by Sunho on 8/31/24.
//

import ComposableArchitecture

@Reducer
struct AddTicketFeature {
    @Reducer(state: .equatable)
    enum BottomSheetState{
        case departureSelection
        case traveTypeSeleciton
        case dateSelection
    }
    @ObservableState
    struct State: Equatable {
        @Presents var bottomSheet: BottomSheetState.State?
    }
    enum Action {
        case bottomSheet(PresentationAction<BottomSheetState.Action>)
        case showDepartuare
        case showDateSelection
        case showkeywords
//        case showfriens
    }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .bottomSheet(.presented(.departureSelection)):
                return .none
            case .bottomSheet:
                return .none
            case .showDepartuare:
                state.bottomSheet = .departureSelection
                return .none
            case .showDateSelection:
                state.bottomSheet = .dateSelection
                return .none
            case .showkeywords:
                state.bottomSheet = .traveTypeSeleciton
                return .none
//            case .showfriens:
//                state.bottomSheet = .friendSelection
//                return .none
            }
        }
        .ifLet(\.$bottomSheet, action: \.bottomSheet)
    }
}
