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
        var tickets: Int = 0
        var memoryFeature: MemoryFeature.State = MemoryFeature.State()
        var addFeature: AddTravelFeature.State = .init()
    }
    enum Action: BindableAction {
         case binding(BindingAction<State>)
        case memoryFeature(MemoryFeature.Action)
        case addTravelFeature(AddTravelFeature.Action)
        case touchnum
    }
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.memoryFeature, action: \.memoryFeature) {
            MemoryFeature()
             }
        Scope(state: \.addFeature, action: \.addTravelFeature) {
              AddTravelFeature()
          }
        Reduce {state, action in
            switch action {
            case .binding:
                return .none
            case .memoryFeature:
                return .none
            
            case .touchnum:
                return .none
            case .addTravelFeature(.path(.element(id: _, action: .makeTicket(.tapmakeTicket)))):
                state.tickets += 1
                state.addFeature.path.removeAll()
                return .none
            case .addTravelFeature:
                return .none
            }
        }
    
    }
}
