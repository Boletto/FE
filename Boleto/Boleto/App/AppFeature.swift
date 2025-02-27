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
import Combine

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var allTicketState: AllTicketsOverViewFeature.State = .init()
        var loginState: LoginFeature.State = .init()
        var profileState: MyProfileFeature.State = .init( mode: .add)
        var monitoringState: LocationMointoringFeature.State = .init()
        var navigationState = NavigationFeature.State()
        var authState = AuthFeature.State()
        var friendState = FriendManagementFeature.State()
        @Shared(.appStorage("currentSpotType")) var currentSpot: SpotType?
        var pendingInviteCode: String? = nil  // 임시 저장용 초대 코드
        var isNotificationEnabled = false
        var showFriendModal: Bool = false
        var invitedFriendName: String?
        var invitedFriendCode: String?
        var userID: Int?
        @Presents var alert: AlertState<Action.Alert>?
        
        var viewstate: ViewState = .splash
        enum ViewState: Equatable {
            case splash
            case agreement
            case setProfile
            case loggedIn
            case loggedOut
            case tutorial
        }
        
        
    }

    enum Action: BindableAction {
        case binding(BindingAction<State> )
        case allTicket(AllTicketsOverViewFeature.Action)
        case login(LoginFeature.Action)
        case profile(MyProfileFeature.Action)
        case monitoring(LocationMointoringFeature.Action)
        case auth(AuthFeature.Action)
        case navigation(NavigationFeature.Action)
        case friend(FriendManagementFeature.Action)
        case startMonitoring(SpotType)
        case stopMonitoring
        
        
        case setViewState(State.ViewState)
        
        case tabAlarms
        case tabmyPage

        case setPendingInviteCode(String)
        case alert(PresentationAction<Alert>)
        case showFriendAlert(String)
        case showAlert(String, Bool)
        case openFriendModal((String,String))
        case acceptFriend
        case rejectFriend
        case initialLogin
        case sessionExpired
        case updateEventType
        enum Alert: Equatable {
            case sessionExpired
        }
    }
    
    @Dependency(\.userClient) var userClient
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.friendClient) var friendClient
    @Dependency(\.stickerDatabase) var stickerDBClient
    @Dependency(\.frameDBClient) var frameDBClient
    @Dependency(\.systemClient) var systemClient
    @Dependency(\.locationClient) var locationClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.authState, action: \.auth) {
            AuthFeature()
        }
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
        Scope(state: \.friendState, action: \.friend) {
            FriendManagementFeature()
        }
        Scope(state: \.navigationState, action: \.navigation) {
            NavigationFeature()
        }
        Reduce { state, action in
            switch action {
            case .auth(.loginSuccess):
                state.viewstate = .loggedIn
                return .send(.friend(.checkPendingInviteCode))
                
            case .auth(.sessionExpired):
                state.viewstate = .loggedOut
                return .send(.navigation(.popAll))
            case .auth(.initialLogin):
                state.viewstate = .loggedIn
                return .concatenate(
                    .send(.auth(.initialLogin)),
                    .send(.navigation(.push(.rewardView)))
                )
                
                
            case .login(.loginSuccess):
                return .run {send in
                    let isFrameEmpty = try await frameDBClient.isEmpty()
                    let isStickerEmpty = try await stickerDBClient.isEmpty()
                    if isFrameEmpty || isStickerEmpty {
                        await send(.auth(.initialLogin))
                    } else {
                        //                        if let fcmToken = KeyChainManager.shared.read(key: .deviceToken) {
                        //                            try await userClient.putFCMToken(fcmToken)
                        //                        }
                        await send(.auth(.loginSuccess))
                    }
                }
                
            case .navigation(.goRoot):
                return .send(.auth(.sessionExpired))
                //                return .run {send in
                //
                //                    send(.stopMonitoring)
                //                }
                
            case .alert(.presented(.sessionExpired)):
                
                return .concatenate(
                    .send(.auth(.sessionExpired)),
                    .send(.setViewState(.loggedOut))
                )
                
                
                
            case .profile(.updateUserInfo):
                if state.profileState.mode == .add {
                    state.viewstate = .tutorial
                }
                return .none
            case .profile:
                return .none
            case .monitoring:
                return .none
            case let .setViewState(viewState):
                if let idString = KeyChainManager.shared.read(key: .userid), let id = Int(idString) {
                    state.userID = id
                } else {
                    print("유저 ID를 가져올 수 없습니다.")
                }
                state.viewstate = viewState
                return .none
        
            case .allTicket(.touchAddTravel):
                return .send(.navigation(.pushAddTicket))
            case .allTicket(.startMonitoirng(let spottype)):
                return .run {send in
                    await send(.startMonitoring(spottype))
                }
            case .allTicket(.stopMonitoring):
                return .run { send in
                    await send(.stopMonitoring)
                }
            case .allTicket(.touchTicket(let ticket)):
                return .send(.navigation(.pushDetaitlEditView(ticket, state.userID!)))
            case .allTicket(.sessionExpired):
                return .send(.sessionExpired)
            case .allTicket:
                return .none
            case .tabAlarms:
                return .send(.navigation(.pushAlarms))
            case .tabmyPage:
                return .send(.navigation(.pushMyPage))
                
            case .startMonitoring(let spot):
                return .run {send in
                    await send(.monitoring(.checkMonitoring(spot)))
                }
            case .stopMonitoring:
                return .run { send in
                    await send(.monitoring(.stopMonitoring))
                }
                
            case .login(.moveToAgreement):
                state.viewstate = .agreement
                return .none

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
                        await send(.showAlert("친구 추가가 완료되었습니다.",true))
                    } catch let error as CustomError {
                        if case let .badRequest(message, _) = error {
                            await send(.showAlert(message, false))
                        } else {
                            await send(.showAlert("알수없는 에러발생", false))
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
                    }catch let error as CustomError {
                        await send(.showAlert(error.message, false))
                        
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
                
                
            case .sessionExpired:
                state.alert = AlertState {
                    TextState("세션 만료")
                } actions: {
                    ButtonState(action: .sessionExpired) {
                        TextState("확인")
                    }
                } message: {
                    TextState("세션이 만료되었습니다. 다시 로그인해주세요.")
                }
                return .none
            default: return .none
            }
            
        }
            .ifLet(\.$alert, action: \.alert)
        
    }}
