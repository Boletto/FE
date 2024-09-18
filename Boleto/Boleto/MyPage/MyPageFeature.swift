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
//        var path = StackState<Path.State>()
    }
    
//    @Reducer(state: .equatable)
//    enum Path {
//        case profile(MyProfileFeature)
//        case mySticker(MyStickerFeature)
//        case myPhotos(MyphotoFeature)
//        case friendLists(MyFriendListsFeature)
//        case invitedTravel(MyInvitedFeature)
//        case notfication(NotificationFeature)
//
//    }
    
    enum Action {
//        case path(StackActionOf<Path>)
        case profileTapped
        case travelPhotosTapped
        case stickersTapped
        case friendListTapped
        case invitedTravelsTapped
//        case notfiTapped
    }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
           
                return .none
            
        }
    }
}
