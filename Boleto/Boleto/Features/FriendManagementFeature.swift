//
//  FriendManagementFeature.swift
//  Boleto
//
//  Created by Sunho on 2/27/25.
//

import ComposableArchitecture
@Reducer
struct FriendManagementFeature {
    @ObservableState
    struct State {
        var pendingInviteCode: String?
        var invitedFriendName: String?
        var invitedFriendCode: String?
//        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action {
        case checkPendingInviteCode
        case showFriendAlert(String)
        case acceptFriend
//        case alert(PresentationAction<Alert>)
    }
    
    @Dependency(\.friendClient) var friendClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .checkPendingInviteCode:
                if let code = state.pendingInviteCode {
                    return .send(.showFriendAlert(code))
                }
                return .none
                
            case .showFriendAlert(let code):
                return .none
//                return .run { send in
//                    let name = try await friendClient.getInfoByCode(code)
//                    state.invitedFriendName = name
//                    state.invitedFriendCode = code
//                }
//                
            case .acceptFriend:
                return .run { [code = state.invitedFriendCode] send in
                    try await friendClient.postAddFriend(code!)
//                    state.alert = AlertState { TextState("친구 추가가 완료되었습니다.") }
                }
                
//            case .alert:
//                return .none
            }
        }
    }
}
