////
////  AppRouteReducer.swift
////  Boleto
////
////  Created by Sunho on 12/8/24.
////
//
//import SwiftUI
//import ComposableArchitecture
//
//@Reducer
//struct AppRouteReducer {
//    struct State: Equatable {
//        var path: StackState<Destination> = .init()
//    }
//
//    @Reducer(state: .equatable)
//    enum Destination: Equatable {
//        case pushSettingView(PushSettingFeature.State)
//        case alarmsView(AlarmsFeature.State)
//        case detailEditView(DetailTravelFeature.State)
//        case addticket(AddTicketFeature.State)
//        case myPage(MyPageFeature.State)
//        case editProfile(MyProfileFeature.State)
//        case mySticker(MyStickerFeature.State)
//        case myPhotos(MyphotoFeature.State)
//        case friendLists(FriendsFeature.State)
//        case invitedTravel(MyInvitedFeature.State)
//        case frameNotificationView(FrameNotificationFeature.State)
//        case badgeNotificationView(BadgeNotificationFeature.State)
//    }
//
//    enum Action: Equatable {
//        case push(Destination)
//        case pop
//        case popToRoot
//        case path(StackActionOf<Destination>)
//    }
//
//    var body: some ReducerOf<Self> {
//        Reduce { state, action in
//            switch action {
//            case .push(let destination):
//                state.path.append(destination)
//                return .none
//            case .pop:
//                state.path.popLast()
//                return .none
//            case .popToRoot:
//                state.path.removeAll()
//                return .none
//            case .path:
//                return .none
////            }
//        }
//        .forEach(\.path, action: \.path)
//    }
//}
