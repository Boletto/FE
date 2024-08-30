//
//  MainTravelFeatrue.swift
//  Boleto
//
//  Created by Sunho on 8/23/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct MainTravelFeatrue {
    @ObservableState
    struct State: Equatable{
        var currentTab: Int  = 0
        var memoryFeature: MemoryFeature.State = MemoryFeature.State()
    }
    enum Action: BindableAction {
         case binding(BindingAction<State>)
        case memoryFeature(MemoryFeature.Action)
    }
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.memoryFeature, action: \.memoryFeature) {
                 MemoryFeature()
             }
        Reduce {state, action in
            switch action {
            case .binding:
                return .none
            case .memoryFeature:
                return .none
            }
        }
    
    }
}
