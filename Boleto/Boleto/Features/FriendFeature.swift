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
        let baseUrlString = "https://boletto.site/invite"
        let shareMessage = "볼레또에 함께하여 친구를 맺으세요. 볼레또에서 다양한 추억을 만들어보세요."
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
        case failedTosessionExpired
        case failedToLoadFriends(String)
        case failedToDeleteFriend(String)
        case finishSelectFriend
        case alert(PresentationAction<Alert>)
        enum Alert: Equatable {
            case confirmDeletion(Int)
            case sessionExpired
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

                            await send(.failedTosessionExpired)
                     
                    }
                }
            case .updateFriends(let friends):
                if state.selectedFriends.isEmpty {
                    state.friends = friends
                } else {
                
                    let mergedFriends = (state.friends + friends).reduce(into: [Int: MemberModel]()) { result, friend in
                        result[friend.id] = friend
                    }
                    state.friends = Array(mergedFriends.values)
                        .sorted {$0.nickname < $1.nickname}
                }
           
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
                return .concatenate(
                       .run { send in
                           do {
                               try await friendClient.deleteFriend(friendID)
                           } catch {
                               await send(.failedToDeleteFriend(error.localizedDescription))
                           }
                       },
                       .run { send in
                           await send(.successDelete)
                           await send(.fetchFriends)
                       }
                   )
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
                return .none
            case .finishSelectFriend:
                return .none
            case .failedTosessionExpired:
                state.alert = AlertState {
                    TextState("오류")
                } actions: {
                    ButtonState(action: .sessionExpired) {
                        TextState("확인")
                    }
                } message: {
                    TextState("세션이 만료되었습니다. 다시 로그인해주세요")
                }
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
