//
//  SpotSelectionFeature.swift
//  Boleto
//
//  Created by Sunho on 9/3/24.
//

import ComposableArchitecture

@Reducer
struct SpotSelectionFeature {
    @ObservableState
    struct State {
        var isDepartureStep = true
        var selectedSpot: SpotType?
        var selectedDeparture: SpotType?
        var selectedArrival: SpotType?
    }
    enum Action {
        case nextStep
        case selectSpot(SpotType)
        case sendSpots
    }
    var body: some ReducerOf<Self> {
        Reduce {state, action in
            switch action {
            case .nextStep:
                if state.isDepartureStep {
                    state.selectedDeparture = state.selectedSpot
                    state.isDepartureStep = false
                } else {
                    state.selectedArrival = state.selectedSpot
                    return .send(.sendSpots)
                }
                state.selectedSpot = nil
                return .none
            case .selectSpot(let spot):
                state.selectedSpot = spot
                return .none
            case .sendSpots:
                return .none
            }
        }
    }
}
