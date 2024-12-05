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
        var showFriendModal: Bool = false
        var invitedFriendName: String?
        var invitedFriendCode: String?
        
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
        case friendLists(FriendsFeature)
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
        case startMonitoring(SpotType)
        case tabNotification
        case sendToFrameView(SpotType)
        case sendToBadgeView(StickerCodes)
        case sendToInvitedView(Int)
        case tabmyPage
        case path(StackActionOf<Destination>)
        case popAll
        case requestLocationAuthorizaiton
        case authorizationResponse(CLAuthorizationStatus?)
        case stopMonitoring(SpotType)
        case setViewState(State.ViewState)
        case fetchMyStickers
        case fetchMyFrames
        case setPendingInviteCode(String)
        case alert(PresentationAction<Alert>)
        case showFriendAlert(String)
        case showAlert(String, Bool)
        case openFriendModal((String,String))
        case acceptFriend
        case rejectFriend
        case initializeApp
        enum Alert: Equatable {
            //            case acceptFriend(String)
        }
    }
    @Dependency(\.userClient) var userClient
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.friendClient) var friendClient
    @Dependency(\.stickerDatabase) var stickerDBClient
    @Dependency(\.frameDBClient) var frameDBClient
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
                    let myStickerImages = try await userClient.getStickers()
                    try await stickerDBClient.updateStickerDB(myStickerImages)
                }
            case .fetchMyFrames:
                return .run {send in
                    let myFrames = try await userClient.getUserFrames()
                    try await frameDBClient.updateFrame(myFrames)
                }
            case .profile(.selectMode(let mode)):
                state.profileState.mode = mode
                return .none
            case .profile(.updateUserInfo):
                if state.profileState.mode == .add {
                    state.viewstate = .tutorial
                    return .run { send in
                        try await stickerDBClient.fetchAllSystem()
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
                    state.path.append(.friendLists(FriendsFeature.State()))
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
                    return .run { send in
                        await send(.monitoring(.checkMonitoringStatus))
                    }
                case .element(id: let id, action: .detailEditView(.touchEditView)):
                    if case let .detailEditView(detailState) = state.path[id: id] {
                        state.path.append(.addticket(AddTicketFeature.State(mode: .edit(detailState.ticket))))
                    }
                    return .none
                case .element(id: _, action: .myPage(.goLoginView)):
                    state.isLogin = false
                    state.viewstate = .loggedOut
                    state.path.removeAll()
                    
                    return .none
                case .element(id: _, action: .alarmsView(.tapAlarmRow(let alarmModel))):
                    switch alarmModel.alarmType {
                    case .sticker:
                        state.path.append(.badgeNotificationView(BadgeNotificationFeature.State(badgeType: StickerCodes(rawValue: alarmModel.value)  ?? .bs01)))
                    case .regionActive:
                        state.path.append(.frameNotificationView(FrameNotificationFeature.State(badgeType: SpotType.fromKoreanString(alarmModel.value) ?? .dummy )))
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
            case .sendToInvitedView(let travelId):
                state.path.append(.invitedTravel(MyInvitedFeature.State(invitedTravelID: travelId)))
                return .none
            case .allTicket(.touchAddTravel):
                state.path.append(.addticket(AddTicketFeature.State()))
                return .none
            case .allTicket(.touchTicket(let ticket)):
                state.path.append(.detailEditView(DetailTravelFeature.State(ticket: ticket)))
                return .none
            case .allTicket:
                return .none
            case .tabNotification:
                state.path.append(.alarmsView(AlarmsFeature.State()))
                return .none
            case .tabmyPage:
                state.path.append(.myPage(MyPageFeature.State()))
                return .none
                
            case .popAll:
                state.path.removeAll()
                return .none
            case .requestLocationAuthorizaiton:
                return .none
            case let .authorizationResponse(status):
                return .none
            case .startMonitoring(let spot):
                return .run {send in
                    try await locationClient.startMonitoring(spot)
                }
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
                    await send(.fetchMyStickers)
                    await send(.fetchMyFrames)
                    
                }
            case .login:
                return .none
            case .binding:
                return .none
            case .setPendingInviteCode(let code):
                state.pendingInviteCode = code
                return .none
            case .acceptFriend:
                return .run {[code = state.invitedFriendCode] send in
                    do{
                        guard let code = code else {return}
                        try await friendClient.postAddFriend(code)
                        await send(.showAlert("친구에 추가가 되었습니다.",true))
                    } catch let error as PostFriendError {
                        switch error {
                        case .expiredFriendCode:
                            await send(.showAlert("만료된 친구 코드입니다.",false))
                        case .usedFriendCode:
                            await send(.showAlert("이미 사용된 친구 코드입니다.",false))
                        case .selfFriendCode:
                            await send(.showAlert("자신의 친구 코드는 사용할 수 없습니다.",false))
                        case .unknownCode:
                            await send(.showAlert("알 수 없는 오류가 발생했습니다.",false))
                        }
                    }
                }
            case .rejectFriend:
                state.invitedFriendCode = nil
                state.invitedFriendName = nil
                return .none
            case .alert:
                return .none
            case .showFriendAlert(let code):
                return .run { send in
                    do {
                        let name = try await friendClient.getInfoByCode(code)
                        await send(.openFriendModal((code, name)))
                    } catch {
                        
                    }
                    
                }
            case .openFriendModal((let code, let name)):
                state.invitedFriendCode = code
                state.invitedFriendName = name
                return .none
                
            case .showAlert(let message, let isSuccss):
                
                state.alert = AlertState {
                    TextState(isSuccss ? "성공" : "오류")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(message)
                }
                return .send(.rejectFriend)
            case .initializeApp:
                return .run {send in
                    try await stickerDBClient.fetchAllSystem()
                }
            }
            
        }.forEach(\.path, action: \.path)
            .ifLet(\.$alert, action: \.alert)
        
    }
    
}
