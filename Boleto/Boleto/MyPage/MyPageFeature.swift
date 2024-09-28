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
        @Shared(.appStorage("AlertOn")) var alertOn: Bool = false
        @Shared(.appStorage("LocationOn")) var locationOn: Bool  = false
        @Shared(.appStorage("userID")) var userid = 0
        var notiAlert: Bool = false
        var locationAlert: Bool = false
        var showOutMember = false
        var outMemberState =  OutMemberFeature.State()
        @Presents var alert: AlertState<Action.Alert>?

        init() {
            self.notiAlert = alertOn
            self.locationAlert = locationOn
        }
    }
    
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        case outMemberAction(OutMemberFeature.Action)
        case profileTapped
        case travelPhotosTapped
        case stickersTapped
        case friendListTapped
        case invitedTravelsTapped
       
        case logoutTapped
        case goLoginView
        case tapbackButton
        case toggleOutMemberView
        enum Alert {
            case doLogOut
  
        }
    }
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.locationClient) var locationclient
    @Dependency(\.accountClient) var accountClient
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state:\.outMemberState, action: \.outMemberAction) {
            OutMemberFeature()
        }
        Reduce { state, action in
            switch action {
            case .binding(\.notiAlert):
                state.alertOn = state.notiAlert
                return .run { [alertOn = state.notiAlert] send in
                    if alertOn {
                        try await self.locationclient.requestNotiAuthorization()
                    } else {
                        await self.locationclient.removeAllScheduledNotifications()
                    }
                }
            case .binding(\.locationAlert) :
                state.locationOn = state.locationAlert
                return .run {[locationOn = state.locationAlert] send in
                    if locationOn {
                        let _ = await self.locationclient.requestauthorzizationStatus()
                    } else {
                        
                    }
                }
            case .alert(.presented(.doLogOut)):
                return .run {send in
                    do  {
                        let result = try await accountClient.postLogout()
                        if result {
                            await send(.goLoginView)
                        }
                    } catch {
                        
                    }}
  
            case .toggleOutMemberView:
                state.showOutMember.toggle()
                return .none
            case .goLoginView:
//                state.userid
                return .none
            case .tapbackButton:
                return .run { _ in await self.dismiss() }
 
            case .logoutTapped:
                state.alert = AlertState {
                    TextState("정말 로그아웃하시겠어요?")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                    ButtonState(action: .doLogOut) {
                        TextState("로그아웃")
                    }
                }
                return .none
            case .outMemberAction(.alert(.presented(.doEraseMember))):
                let userid = state.userid
                return .run { send in
                    do  {
                        let result = try await accountClient.deleteMemeber()
                        if result {
                            await send(.goLoginView)
                        }
                    } catch {
                        
                    }
                    
                }
            default:
                return .none
            }
        }.ifLet(\.$alert, action: \.alert)
    }
}
