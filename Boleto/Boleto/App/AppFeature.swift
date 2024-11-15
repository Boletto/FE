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
        var allTicketState: AllTicketsOverViewFeature.State = .init()
        var loginState: LoginFeature.State = .init()
        var profileState: MyProfileFeature.State = .init()
        var monitoringState: LocationMointoringFeature.State = .init()
        
        @Shared(.appStorage("isMonitoring")) public var isMonitoring = false
        @Shared(.appStorage("isLogin")) var isLogin: Bool = false
        @Shared(.appStorage("name")) var name: String = ""
        @Shared(.appStorage("profile")) var profile: String = ""
        @Shared(.appStorage("nickname")) var nickname : String = ""
        var pendingInviteCode: String? = nil  // 임시 저장용 초대 코드
        var isNotificationEnabled = false
        var path =  StackState<Destination.State>()
        var viewstate: ViewState = .loggedOut
        @Presents var alert: AlertState<Action.Alert>?
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
        case alarmsView(AlarmsFeature)
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
        case allTicket(AllTicketsOverViewFeature.Action)
        case login(LoginFeature.Action)
        case profile(MyProfileFeature.Action)
        case monitoring(LocationMointoringFeature.Action)
        case tabNotification
        case sendToFrameView(SpotType)
        case sendToBadgeView(StickerImage)
        case tabmyPage
        case path(StackActionOf<Destination>)
        case popAll
        case requestLocationAuthorizaiton
        case authorizationResponse(CLAuthorizationStatus?)
        case stopMonitoring(SpotType)
        case toggleNoti(Bool)
        case setViewState(State.ViewState)
        case fetchMyStickers
        case backgroundRefresh
        case setPendingInviteCode(String)
        case alert(PresentationAction<Alert>)
        case showFriendAlert(String)
        case showErrorAlert(String)
        enum Alert: Equatable {
            case acceptFriend(String)
        }
    }
    @Dependency(\.userClient) var userClient
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.stickerClient ) var stickerClient
    @Dependency(\.friendClient) var friendClient
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.monitoringState, action: \.monitoring) {
            LocationMointoringFeature()
        }
        Scope(state: \.allTicketState , action: \.allTicket) {
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
            case .monitoring:
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
                case .element(id: _, action: .alarmsView(.tapAlarmRow(let alarmModel))):
                    switch alarmModel.alarmType {
                    case .sticker:
                        state.path.append(.badgeNotificationView(BadgeNotificationFeature.State(badgeType: StickerImage.fromEnglishString(alarmModel.value) ?? .khu)))
                    case .regionActive:
                        state.path.append(.frameNotificationView(FrameNotificationFeature.State(badgeType: SpotFactory.fromString(alarmModel.value) ?? .school )))
                    default:
                        state.path.removeAll()
                    }
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
            case .allTicket(.touchAddTravel):
                state.path.append(.addticket(AddTicketFeature.State()))
                return .none
            case .allTicket(.touchTicket(let ticket)):
                state.path.append(.detailEditView(DetailTravelFeature.State(ticket: ticket)))
                return .none
            case .allTicket(.updateTickets) :
                state.monitoringState.currentTicket = state.allTicketState.currentTicket
                return .run { send in
                    await send(.monitoring(.checkMonitoringStatus))
                }
                return .none
            case .allTicket:
                return .none
            case .tabNotification:
                state.path.append(.alarmsView(AlarmsFeature.State()))
                return .none
            case .tabmyPage:
                state.path.append(.myPage(MyPageFeature.State()))
                return .none
            case .backgroundRefresh:
                return .send(.monitoring(.checkMonitoringStatus))
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
                
            case .stopMonitoring(let spot):
                return .run { send in
                    try await locationClient.stopMonitoring(spot)
                }
                
            case .login(.moveToProfile):
                state.viewstate = .setProfile
                return .none
            case .login(.loginSuccess(let user)):
                state.viewstate = .loggedIn
                state.isLogin = true
                state.name = user.name
                state.profile = user.profileImage
                state.nickname = user.nickName
                return .run { send in
                    if let fcmToken = KeyChainManager.shared.read(key: .deviceToken) {
                        try await userClient.putFCMToken(fcmToken)
                    }
                    
                }
            case .login:
                return .none
            case .toggleNoti(let bool):
                state.isLogin = false
                if bool {
                    
                }
                return .none
            case .binding:
                return .none
            case .setPendingInviteCode(let code):
                state.pendingInviteCode = code
                return .none
            case .alert(.presented(.acceptFriend(let code))):
                return .run {send in
                    do{
                        try await friendClient.postAddFriend(code)
                    } catch let error as PostFriendError {
                        switch error {
                        case .expiredFriendCode:
                            await send(.showErrorAlert("만료된 친구 코드입니다."))
                        case .usedFriendCode:
                            await send(.showErrorAlert("이미 사용된 친구 코드입니다."))
                        case .selfFriendCode:
                            await send(.showErrorAlert("자신의 친구 코드는 사용할 수 없습니다."))
                        case .unknownCode:
                            await send(.showErrorAlert("알 수 없는 오류가 발생했습니다."))
                        }
                    }
                }
            case .alert:
                return .none
            case .showFriendAlert(let code):
                state.alert = AlertState {
                    TextState("친구하기")
                } actions: {
                    ButtonState(role: .destructive) {
                        TextState("거절")
                            .foregroundColor(.red)
                    }
                    ButtonState( action: .acceptFriend(code)) {
                        TextState("승낙")
                            .foregroundColor(.blue)
                    }
                } message: {
                    TextState("이 친구와 친구하시겠습니까?")
                }
                return .none
            case .showErrorAlert(let message):
                state.alert = AlertState {
                    TextState("오류")
                } actions: {
                    ButtonState(role: .destructive) {
                        TextState("확인")
                    }
                } message: {
                    TextState(message)
                }
                return .none
            }
            
        }.forEach(\.path, action: \.path)
            .ifLet(\.$alert, action: \.alert)
        
    }
    
}
