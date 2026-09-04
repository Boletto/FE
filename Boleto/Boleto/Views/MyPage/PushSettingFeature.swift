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
    enum Action {
        case setGetNotification(Bool)
        case setFriendNotification(Bool)
        case setInvitationNotification(Bool)
    }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .setGetNotification(isOn):
                state.$getnotiAlert.withLock { $0 = isOn }
                return .none
            case let .setFriendNotification(isOn):
                state.$frinedAlert.withLock { $0 = isOn }
                return .none
            case let .setInvitationNotification(isOn):
                state.$invitedAlert.withLock { $0 = isOn }
                return .none
            }
        }
    }
}
