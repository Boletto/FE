//
//  AppFeature.swift
//  Boleto
//
//  Created by Sunho on 9/7/24.
//

import SwiftUI
import ComposableArchitecture
import CoreLocation
import UserNotifications
import AuthenticationServices

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var pastTravel: AllTicketsOverViewFeature.State = .init()
        var loginState: LoginFeature.State = .init()
        var profileState: MyProfileFeature.State = .init()
        
        @Shared(.appStorage("isMonitoring")) public var isMonitoring = false
        @Shared(.appStorage("isLogin")) var isLogin: Bool = false
        @Shared(.appStorage("name")) var name: String = ""
        @Shared(.appStorage("profile")) var profile: String = ""
        @Shared(.appStorage("nickname")) var nickname : String = ""
        var isNotificationEnabled = false
        var monitoringEvents: [MonitorEvent] = []
        
        var path =  StackState<Destination.State>()
        var viewstate: ViewState = .loggedOut
        enum ViewState: Equatable {
            case setProfile
            case loggedIn
            case loggedOut
            case tutorial
        }
        
    }
    @Reducer(state: .equatable)
    enum Destination {
        case pushSettingView(PushSettingFeature)
        case notifications(NotificationFeature)
        case detailEditView(DetailTravelFeature)
        case addticket(AddTicketFeature)
        case myPage(MyPageFeature)
        case editProfile(MyProfileFeature)
        case mySticker(MyStickerFeature)
        case myPhotos(MyphotoFeature)
        case friendLists(MyFriendListsFeature)
        case invitedTravel(MyInvitedFeature)
        case frameNotificationView(FrameNotificationFeature)
        case badgeNotificationView(BadgeNotificationFeature)
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State> )
        case pastTravel(AllTicketsOverViewFeature.Action)
        case login(LoginFeature.Action)
        case profile(MyProfileFeature.Action)
        case tabNotification
        case sendToFrameView(Spot)
        case sendToBadgeView(StickerImage)
        case tabmyPage
        case path(StackActionOf<Destination>)
        case popAll
        case requestLocationAuthorizaiton
        case authorizationResponse(CLAuthorizationStatus?)
        //        case toggleMonitoring(Spot)
        case monitoringEvent(Spot)
        case stopMonitoring(Spot)
        //        case scheduleNotification(Spot)
        case toggleNoti(Bool)
        case setViewState(State.ViewState)
        case fetchMyStickers
        //        case updateMyStickers([StickerImage])

        
        
    }
    @Dependency(\.userClient) var userClient
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.stickerClient ) var stickerClient
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.pastTravel, action: \.pastTravel) {
            AllTicketsOverViewFeature()
        }
        Scope(state:\.loginState, action: \.login) {
            LoginFeature()
        }
        Scope(state: \.profileState, action: \.profile) {
            MyProfileFeature()
        }
        Reduce { state, action in
            switch action {
            case .fetchMyStickers:
                return .run { send in
                    //                    return .run { send in
                    try stickerClient.initializeBadges()
                    //                    }
                    let myStickerImages = try await userClient.getStickers()
                    try  stickerClient.updateCollectedBadges(myStickerImages)
                    //                    let mystickers =  try stickerClient.fetchMyBadges()
                    //                    await send(.updateMyStickers(mystickers))
                    
                }
                
            case .profile(.selectMode(let mode)):
                state.profileState.mode = mode
                return .none
            case .profile(.updateUserInfo):
                if state.profileState.mode == .add {
                    state.viewstate = .tutorial
                    //                    state.
                    return .run { send in
                        try stickerClient.initializeBadges()
                    }
                }
                return .none
            case .profile:
                return .none
            case let .setViewState(viewState):
                state.viewstate = viewState
                return .none
            case let .path(action):
                switch action {
                case .element(id: _, action: .myPage(.friendListTapped)):
                    state.path.append(.friendLists(MyFriendListsFeature.State()))
                    return .none
                case .element(id: _, action: .myPage(.profileTapped)):
                    state.path.append(.editProfile(MyProfileFeature.State()))
                    return .none
                case .element(id: _, action: .myPage(.invitedTravelsTapped)):
                    state.path.append(.invitedTravel(MyInvitedFeature.State()))
                    return .none
                case .element(id: _, action: .myPage(.travelPhotosTapped)):
                    state.path.append(.myPhotos(MyphotoFeature.State()))
                    return .none
                case .element(id: _, action: .myPage(.stickersTapped)):
                    state.path.append(.mySticker(MyStickerFeature.State()))
                    return .none
                case .element(id: _, action: .myPage(.pushSettingTapped)):
                    state.path.append(.pushSettingView(PushSettingFeature.State()))
                    return .none
                case .element(id: _, action: .addticket(.tapbackButton)):
                    state.path.popLast()
                    return .none
                case .element(id: _, action: .addticket(.successTicket)):
                    state.path.popLast()
                    //그리고 다시 리프레쉬 기능 해야함 여기서
                    return .none
                case .element(id: let id, action: .detailEditView(.touchEditView)):
                    if case let .detailEditView(detailState) = state.path[id: id] {
                        state.path.append(.addticket(AddTicketFeature.State(mode: .edit(detailState.ticket))))
                    }
                    return .none
                case .element(id: _, action: .myPage(.goLoginView)):
                    //                    state.currentLogin = false
                    //                    KeyChainManager.shared.deleteAll()
                    
                    state.isLogin = false
                    state.viewstate = .loggedOut
                    state.path.removeAll()
                    
                    return .none
                default:
                    return .none
                }
            case .sendToBadgeView(let stickertype):
                
                state.path.append(.badgeNotificationView(BadgeNotificationFeature.State(badgeType: stickertype)))
                return .none
            case .sendToFrameView(let spot):
                state.path.append(.frameNotificationView(FrameNotificationFeature.State( badgeType: spot)))
                return .none
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
            case .requestLocationAuthorizaiton:
                return .none
                //                return .run {send in
                ////                    let status  = await locationClient.requestauthorzizationStatus()
                //                    await send(.authorizationResponse(status))
                //                }
            case let .authorizationResponse(status):
                //                state.authorizationStatus = status
                return .none
            case .monitoringEvent(let spot):
                
                return .run { send in
                    do {
                        for try await event in try await locationClient.startMonitoring(spot) {
                            switch event {
                            case .didEnterFrameRegion:
                                try await notificationClient.add(FrameNotification(id: spot.name))
                            case .didEnterBadgeRegion(let sticker):
                                try await notificationClient.add(BadgeNotification(id: sticker.rawValue, stickerImageType: sticker))
                            }
                        }
                    } catch {
                        print("Monitoring error: \(error)")
                    }
                }
            case .stopMonitoring(let spot):
                return .run { send in
                    try await locationClient.stopMonitoring(spot)
                }
                
            case .login(.moveToProfile):
                state.viewstate = .setProfile
                return .none
            case .login(.loginSuccess(let user)):
                //                state.currentLogin = true
                state.viewstate = .loggedIn
                state.isLogin = true
                state.name = user.name
                state.profile = user.profileImage
                state.nickname = user.nickName
                return .none
            case .login:
                return .none
            case .toggleNoti(let bool):
                state.isLogin = false
                if bool {
                    
                }
                return .none
            case .binding:
                return .none
                
            }
            
        }.forEach(\.path, action: \.path)
        
    }
    
}
