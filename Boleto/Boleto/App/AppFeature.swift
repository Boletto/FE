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
        @Shared(.appStorage("userId")) var userID: Int?
        
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
    
    enum Action {
        case allTicket(AllTicketsOverViewFeature.Action)
        case login(LoginFeature.Action)
        case profile(MyProfileFeature.Action)
        case monitoring(LocationMointoringFeature.Action)
        case auth(AuthFeature.Action)
        case navigation(NavigationFeature.Action)
        case friend(FriendManagementFeature.Action)
        case setViewState(State.ViewState)
        case tabAlarms
        case tabmyPage
        case setPendingInviteCode(String)
        case alert(PresentationAction<Alert>)
        case showAlert(String, Bool)
        case openFriendModal((String,String))
        case initialLogin
        case sessionExpired
        case updateEventType
        enum Alert: Equatable {
            case sessionExpired
        }
    }
    
    @Dependency(\.stickerDatabase) var stickerDBClient
    @Dependency(\.frameDBClient) var frameDBClient
    
    var body: some ReducerOf<Self> {
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
            case .initialLogin:   
                return .run {send in
                    await send(.auth(.initialLogin))
                }
            case .auth(.loginSuccess):
                state.viewstate = .loggedIn
                return .send(.friend(.checkPendingInviteCode))
                
            case .auth(.sessionExpired):
                return .send(.navigation(.goRoot))
   
            case .navigation(.goRoot):
                state.viewstate = .loggedOut
                return .run {send in
                    await send(.monitoring(.stopMonitoring))
                }
                
            case .login(.loginSuccess):
                return .run {send in
                    let isFrameEmpty = try await frameDBClient.isEmpty()
                    let isStickerEmpty = try await stickerDBClient.isEmpty()
                    if isFrameEmpty || isStickerEmpty {
                        await send(.auth(.initialLogin))
                    } else {
                        await send(.auth(.loginSuccess))
                    }
                }
            case .login(.moveToAgreement):
                state.viewstate = .agreement
                return .none
                
            case .login:
                return .none
                
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
                    await send(.monitoring(.checkMonitoring(spottype)))
                }
            case .allTicket(.stopMonitoring):
                return .run { send in
                    await send(.monitoring(.stopMonitoring))
                }
            case .allTicket(.touchTicket(let ticket)):
                return .send(.navigation(.pushDetaitlEditView(ticket, state.userID!)))
            case .allTicket(.sessionExpired):
                return .send(.sessionExpired)
                
            case .tabAlarms:
                return .send(.navigation(.pushAlarms))
            case .tabmyPage:
                return .send(.navigation(.pushMyPage))
                
            case .friend(.showAlert(let message, let isSuccss)):
                state.alert = AlertState {
                    TextState(isSuccss ? "성공" : "오류")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(message)
                }
                return .none
                
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
        
    }
    }
