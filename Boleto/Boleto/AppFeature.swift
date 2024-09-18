//
//  AppFeature.swift
//  Boleto
//
//  Created by Sunho on 9/7/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var pastTravel: MainTravelTicketsFeature.State = .init()
        var path =  StackState<Destination.State>()
        
    }
    @Reducer(state: .equatable)
    enum Destination {
        case notifications(NotificationFeature)
        case detailEditView(DetailTravelFeature)
        case addticket(AddTicketFeature)
        case myPage(MyPageFeature)
        case editProfile(MyProfileFeature)
        case mySticker(MyStickerFeature)
        case myPhotos(MyphotoFeature)
        case friendLists(MyFriendListsFeature)
        case invitedTravel(MyInvitedFeature)
        
      }
      
    enum Action {
        case pastTravel(MainTravelTicketsFeature.Action)
        case tabNotification
        case tabmyPage
        case path(StackActionOf<Destination>)
        case popAll
        
    }
    var body: some ReducerOf<Self> {
        Scope(state: \.pastTravel, action: \.pastTravel) {
            MainTravelTicketsFeature()
        }
        Reduce { state, action in
            switch action {
            case let .path(action):
                switch action {
                case .element(id: _, action: .myPage(.profileTapped)):
                    state.path.append(.editProfile(MyProfileFeature.State()))
                    return .none
                case .element(id: _, action: .myPage(.invitedTravelsTapped)):
                    state.path.append(.invitedTravel(MyInvitedFeature.State()))
                    return .none
                case .element(id: _, action: .myPage(.stickersTapped)):
                    state.path.append(.mySticker(MyStickerFeature.State()))
                    return .none
//                case .element(id: _, action: .)
//                case .element(id: _, action: .myPage(.invitedTravelsTapped)):
//                    state.path.append(.invitedTravel(MyInvitedFeature.State()))
//                case .element(id: _, action: .myPage(.invitedTravelsTapped)):
//                    state.path.append(.invitedTravel(MyInvitedFeature.State()))
                default:
                    return .none
                }
            case .pastTravel(.touchAddTravel):
                state.path.append(.addticket(AddTicketFeature.State()))
                return .none
            case .pastTravel(.touchTicket(let ticket)):
                state.path.append(.detailEditView(DetailTravelFeature.State(ticket: ticket)))
                return .none
            case .pastTravel:
                return .none
            case .tabNotification:
                state.path.append(.notifications(NotificationFeature.State()))
                return .none
            case .tabmyPage:
                state.path.append(.myPage(MyPageFeature.State()))
                return .none
            case .popAll:
                state.path.removeAll()
                return .none
            }
        }.forEach(\.path, action: \.path)
    }
    
}
