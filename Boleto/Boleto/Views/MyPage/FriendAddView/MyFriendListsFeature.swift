//
//  MyFriendListsFeature.swift
//  Boleto
//
//  Created by Sunho on 9/12/24.
//

import ComposableArchitecture
@Reducer
struct MyFriendListsFeature {
    @ObservableState
    struct State: Equatable {
        var searchText: String = ""
        var resultFriend: [AllUser] = []
        @Presents var alert: AlertState<Action.Alert>?
    }
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case taperaseField
        case fetchFriend
        case updateFriend([AllUser])
        case addFriend(AllUser)
        case friendAdded(Bool)
        case alert(PresentationAction<Alert>)
//        case dismissAlert
        enum Alert: Equatable {
                    case dismiss
                }
    }
    @Dependency(\.userClient) var userClient
    var body: some  ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .taperaseField:
                state.searchText = ""
                return .none
            case .fetchFriend:
                return .run {send in
                    let users = try await userClient.getAllUsers()
                    await send(.updateFriend(users))
                }
            case .updateFriend(let users):
                state.resultFriend = users
                return .none
            case .addFriend(let user ):
                return .run { send in
                    let result = try await userClient.postFriend(user.id)
                    if result {
                        await send(.friendAdded(true))
                    }
                }
            case .friendAdded(let success):
                     if success {
                         state.alert = AlertState {
                             TextState("친구 추가 완료")
                         } actions: {
                             ButtonState(action: .dismiss) {
                                 TextState("확인")
                             }
                         } message: {
                             TextState("성공적으로 친구가 추가되었습니다.")
                         }
                     }
                     return .none
            case .alert(.dismiss):
                           state.alert = nil
                           return .none
            case .alert:
                return .none
            }
        }.ifLet(\.$alert, action: \.alert)
    }
}
