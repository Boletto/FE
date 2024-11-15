//
//  MyFriendListsFeature.swift
//  Boleto
//
//  Created by Sunho on 9/12/24.
//
import SwiftUI
import ComposableArchitecture

@Reducer
struct MyFriendListsFeature {
    @ObservableState
    struct State: Equatable {
        var searchText: String = ""
        var friendLists = [MemberModel]()
        var shareCode:  String = ""
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case taperaseField
        case updateFriend([MemberModel])
        case shareLinkTapped
        case successDelete
        case alert(PresentationAction<Alert>)
        case getFriendLists
        case updateShareCode(String)
        case tapDeleteFriend(MemberModel)
        case failedToLoadFriends(String)
        case failedToDeleteFriend(String)
        
        enum Alert: Equatable {
            case confirmDeletion(Int)
        }
    }
    @Dependency(\.friendClient) var friendClient
    
    var body: some  ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .taperaseField:
                state.searchText = ""
                return .none
            case .updateFriend(let users):
                state.friendLists = users
                return .none
                
            case .successDelete:
                
                state.alert = AlertState {
                    TextState("친구 삭제 완료")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState("성공적으로 친구가 제거되었습니다.")
                    
                }
                return .run { send in
                    await send(.getFriendLists)
                }
                
            case .getFriendLists:
                return .run { send in
                    do {
                        let friends = try await friendClient.getAllFriends()
                        await send(.updateFriend(friends))
                    } catch {
                        await send(.failedToLoadFriends(error.localizedDescription))
                    }
                }
            case .shareLinkTapped:
                return .run { send in
                    let myCode = try await friendClient.getShareCode()
                    await send(.updateShareCode(myCode))
                }
            case .updateShareCode(let code):
                state.shareCode = code
                return .none
            case .tapDeleteFriend(let model):
                state.alert = AlertState {
                    TextState("친구 삭제")
                } actions : {
                    ButtonState(role:.cancel) {
                        TextState("취소")
                    }
                    ButtonState(role: .destructive, action: .confirmDeletion(model.id)) {
                        TextState("삭제")
                    }
                } message: {
                    TextState("\(model.nickname)과 친구를 끊으시겠습니까?")
                }
                return .none
            case .alert(.presented(.confirmDeletion(let friendID))):
                return .run {send in
                    do {
                        try await friendClient.deleteFriend(friendID)
                        await send(.successDelete)
                    } catch {
                        await send(.failedToDeleteFriend(error.localizedDescription))
                    }
                }
            case .failedToLoadFriends(let error):
                state.alert = AlertState {
                    TextState("오류")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState("친구 목록을 불러오는데 실패했습니다.\n\(error)")
                }
                return .none
            case .failedToDeleteFriend(let error):
                state.alert = AlertState {
                    TextState("오류")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState("친구 삭제에 실패했습니다.\n\(error)")
                }
                return .none
            case .alert:
                return .none
            }
        }.ifLet(\.$alert, action: \.alert)
    }
}
