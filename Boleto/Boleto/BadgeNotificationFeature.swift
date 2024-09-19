//
//  BadgeNotificationFeature.swift
//  Boleto
//
//  Created by Sunho on 9/19/24.
//

import ComposableArchitecture

@Reducer
struct BadgeNotificationFeature {
    @Dependency(\.dismiss) var dimisss
    
    @ObservableState
    struct State: Equatable {
        
    }
    enum Action {
        
    }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
