//
//  TabFeature.swift
//  Boleto
//
//  Created by Sunho on 8/9/24.
//

import SwiftUI
import ComposableArchitecture
@Reducer
struct TabFeature {
    @ObservableState
    struct State {
        var currentTab: Tab = .mainTravel
        enum Tab {
            case pastTravel
            case mainTravel
            case myPage
        }
    }
    enum Action: Equatable {
        case selectTab(State.Tab)
    }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .selectTab(let tab):
                state.currentTab = tab
                return .none
                
            }
        }
    }
}
