//
//  FriendFeature.swift
//  Boleto
//
//  Created by Sunho on 11/21/24.
//
import SwiftUI
import ComposableArchitecture

@Reducer
struct FriendsFeature {
    @ObservableState
    struct State: Equatable {
        var friends = [MemberModel]()
        var selectedFriends : [MemberModel] = []
        var searchText: String = ""
        var openShareLink: Bool = false
        let baseUrlString = "https://boletto.site"
        let shareMessage = "안녕 친구하실?"
        var shareUrl:  URL?
        var filteredFriends: [MemberModel] {
            if searchText.isEmpty {
                return friends
            }
            return friends.filter { $0.nickname.contains(searchText) || $0.name.contains(searchText)}
        }
        @Presents var alert: AlertState<Action.Alert>?
    }
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case taperaseField
        case fetchFriends
        case updateFriends([MemberModel])
        case tapxmark
        case toggleFriendSelection(MemberModel)
        case tapDeleteFriend(MemberModel)
        case successDelete
        
        case shareLinkTapped
        case updateShareCode(String)
        
        case failedToLoadFriends(String)
        case failedToDeleteFriend(String)
        case finishSelectFriend
        case alert(PresentationAction<Alert>)
        enum Alert: Equatable {
            case confirmDeletion(Int)
        }
    }
    @Dependency(\.friendClient) var friendClient
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .tapxmark:
                return .run { _ in
                    await self.dismiss()
                    
                }
            case .fetchFriends:
                return .run {send in
                    do {
                        let friends = try await friendClient.getAllFriends()
                        await send(.updateFriends(friends))
                    } catch {
                        await send(.failedToLoadFriends(error.localizedDescription))
                    }
                }
            case .updateFriends(let friends):
                state.friends = friends
                return .none
            case .taperaseField:
                state.searchText = ""
                return .none
            case .toggleFriendSelection(let friend):
                if let index = state.selectedFriends.firstIndex(where: { $0.id == friend.id }) {
                    state.selectedFriends.remove(at: index)
                } else {
                    state.selectedFriends.append(friend)
                }
                return .none
            case .shareLinkTapped:
                return .run { send in
                    let code = try await friendClient.getShareCode()
                    await send(.updateShareCode(code))
                }
            case .updateShareCode(let code):
                state.shareUrl = URL(string: state.baseUrlString + "/" + code)
                state.openShareLink = true
                return .none
            case .tapDeleteFriend(let model):
                state.alert = AlertState {
                    TextState("친구 삭제")
                } actions: {
                    ButtonState(role: .cancel) {
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
                return .run { send in
                    do {
                        try await friendClient.deleteFriend(friendID)
                        await send(.successDelete)
                    } catch {
                        await send(.failedToDeleteFriend(error.localizedDescription))
                    }
                }
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
                    await send(.fetchFriends)
                }
            case .finishSelectFriend:
                return .none
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
