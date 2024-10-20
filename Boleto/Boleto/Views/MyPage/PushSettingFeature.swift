//
//  PushSettingFeature.swift
//  Boleto
//
//  Created by Sunho on 10/3/24.
//

import Foundation
import ComposableArchitecture
@Reducer
struct PushSettingFeature {
    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("getAlert")) var getnotiAlert = false
        @Shared(.appStorage("friendAlert")) var frinedAlert = false
        @Shared(.appStorage("invitedAlert")) var invitedAlert = false
    }
    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
    }
}
