//
//  NotificationFeature.swift
//  Boleto
//
//  Created by Sunho on 9/14/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct NotificationFeature{
    @Dependency(\.dismiss) var dismiss
    @ObservableState
    struct State: Equatable {
        
    }
    enum Action {
        case tapbackbutton
    }
    var body: some ReducerOf<Self> {
        Reduce {state, action in
            switch action {
            case .tapbackbutton:
                return .run { _ in await self.dismiss() }
                
            }
        }
    }
}
