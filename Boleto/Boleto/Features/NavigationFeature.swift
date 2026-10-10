//
//  NavigationFeature.swift
//  Boleto
//
//  Created by Sunho on 2/27/25.
//

import Foundation
import ComposableArchitecture
enum NavigationDestination: Equatable {
    case pushSetting
    case alarms
    case detailEditView(ticket: Ticket)
    case addTicket(isEdit:Bool = false)
    case myPage
    case editProfile(isFirst: Bool = true)
    case mySticker
    case myFrames
    case friendLists
    case invitedTravel
    case frameNotification(badgeType: SpotType)
    case badgeNotification(badgeType: StickerCodes)
    case reward
}
@Reducer
struct NavigationFeature {
    @ObservableState
    struct State {
        @Shared(.appStorage("isLogin")) var isLogin: Bool = false

        var path = StackState<Destination.State>()
    }
    @Reducer(state: .equatable)
    enum Destination {
        case alarmsView(AlarmsFeature)
        case detailEditView(DetailTravelFeature)
        case addticket(AddTicketFeature)
        case myPage(MyPageFeature)
        case editProfile(MyProfileFeature)
        case mySticker(MyStickerFeature)
        case myFrames(MyphotoFeature)
        case friendLists(FriendsFeature)
        case invitedTravel(MyInvitedFeature)
        case frameNotificationView(FrameNotificationFeature)
        case badgeNotificationView(BadgeNotificationFeature)
        case rewardView
    }
    enum Action {
        case push(Destination.State)
        case goRoot
        case path(StackActionOf<Destination>)
        case showAlert
        case sendToFrameView(SpotType)
        case sendToBadgeView(StickerCodes)
        case sendToInvitedView(Int)
        case pushAddTicket
        case pushDetaitlEditView(Ticket, Int)
        case pushFriendView
        case pushAlarms
        case pushMyPage
    }
    var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .push(let destination):
                    state.path.append(destination)
                    return .none
                case .goRoot:
                    state.isLogin = false
                    state.path.removeAll()
                    return .none

                case .showAlert:
                    return .none
                case .sendToBadgeView(let stickerType ):
                    return .send(.push(.badgeNotificationView(BadgeNotificationFeature.State(badgeType: stickerType))))
                case .sendToFrameView(let spottype):
                    return .send(.push(.frameNotificationView(FrameNotificationFeature.State(badgeType: spottype))))
                case .sendToInvitedView(let travelID):
                    return .send(.push(.invitedTravel(MyInvitedFeature.State(invitedTravelID: travelID))))
                case .pushAddTicket:
                    return .send(.push(.addticket(AddTicketFeature.State())))
                case .pushDetaitlEditView(let ticket, let userid):
                    let editStatus: EditState = ticket.editableID == nil ? .unlocked : (ticket.editableID == userid ? .lockedByMe : .lockedByOthers)
                    return .send(.push(.detailEditView(DetailTravelFeature.State(ticket: ticket,editStatus: editStatus))))
                case .pushFriendView:
                    return .send(.push(.friendLists(FriendsFeature.State())))
                case .pushAlarms:
                    return .send(.push(.alarmsView(AlarmsFeature.State())))
                case .pushMyPage:
                    return .send(.push(.myPage(MyPageFeature.State())))
                case let .path(pathAction):
                    switch pathAction {
                    case .element(id: _, action: .myPage(.friendListTapped)):
                        return .send(.push(.friendLists(FriendsFeature.State())))
                    case .element(id: _, action: .myPage(.profileTapped)):
                        return .send(.push(.editProfile(MyProfileFeature.State(mode: .edit))))
                    case .element(id: _, action: .myPage(.invitedTravelsTapped)):
                        return .send(.push(.invitedTravel(MyInvitedFeature.State())))
                    case .element(id: _, action: .myPage(.travelPhotosTapped)):
                        return .send(.push(.myFrames(MyphotoFeature.State())))
                    case .element(id: _, action: .myPage(.stickersTapped)):
                        return .send(.push(.mySticker(MyStickerFeature.State())))
                    case .element(id: _, action: .myPage(.goLoginView)):
                        return .send(.goRoot)
                    case .element(id: let id, action: .detailEditView(.navigateToEditView)):
                        if case let .detailEditView(detailState) = state.path[id: id] {
                            return .send(.push((.addticket(AddTicketFeature.State(mode: .edit(detailState.ticket))))))
                        }
                        return .none
                    case .element(id: _, action: .alarmsView(.navigateToAlarmDestination(let alarmModel, let value))):
                        switch alarmModel {
                        case .sticker:
                            return .send(.push(.badgeNotificationView(BadgeNotificationFeature.State(badgeType: StickerCodes.fromKoreanString(value) ?? .bs01))))
                        case .regionActive:
                            return .send(.push(.frameNotificationView(FrameNotificationFeature.State(badgeType: SpotType.fromKoreanString(value) ?? .seoul ))))
                        case .invitedTicket:
                            return .send(.push(.invitedTravel(MyInvitedFeature.State(invitedTravelID: Int(value)))))
                        case .travelTicket:
                            return .send(.push(.invitedTravel(MyInvitedFeature.State(invitedTravelID: Int(value)))))
                        case .friendAccept:
                            return .send(.push(.friendLists(FriendsFeature.State())))
                        default:
                            print(alarmModel, value, "오류오류")
                            return .none
         
                        }
                        
             
                    case .element(id: _, action: .friendLists(.alert(.presented(.sessionExpired)))),
                            .element(id: _, action: .detailEditView(.memoryFeature(.inner(.sessionExpired)))),
                            .element(id: _, action: .invitedTravel(.alert(.presented(.sessionExpired)))):
                        return .send(.showAlert)

                    default:
                        return .none
                    }
                }
            }.forEach(\.path, action: \.path)
        }
}
