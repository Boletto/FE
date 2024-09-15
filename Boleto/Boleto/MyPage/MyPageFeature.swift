//
//  MyPageFeature.swift
//  Boleto
//
//  Created by Sunho on 9/11/24.
//

import Foundation
import ComposableArchitecture
import SwiftUI
@Reducer
struct MyPageFeature {
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
    }
    
    @Reducer(state: .equatable)
    enum Path {
        case profile(MyProfileFeature)
        case mySticker(MyStickerFeature)
        case myPhotos(MyphotoFeature)
        case friendLists(MyFriendListsFeature)
        case invitedTravel(MyInvitedFeature)
        case notfication(NotificationFeature)
//        case setting(
     
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        case profileTapped
        case travelPhotosTapped
        case stickersTapped
        case friendListTapped
        case invitedTravelsTapped
        case notfiTapped
    }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .profileTapped:
                state.path.append(.profile(MyProfileFeature.State()))
                return .none
            case .travelPhotosTapped:
                state.path.append(.myPhotos(MyphotoFeature.State()))
                return .none
            case .stickersTapped:
                state.path.append(.mySticker(MyStickerFeature.State()))
                return .none
            case .friendListTapped:
                state.path.append(.friendLists(MyFriendListsFeature.State()))
                return .none
            case .invitedTravelsTapped:
                state.path.append(.invitedTravel(MyInvitedFeature.State()))
                return .none
            case .notfiTapped:
                state.path.append(.notfication(NotificationFeature.State()))
                return .none
            case .path:
                return .none
            }
        }.forEach(\.path, action: \.path)
    }
}
