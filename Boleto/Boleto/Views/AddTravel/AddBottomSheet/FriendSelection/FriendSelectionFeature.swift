//
//  FriendSelectionFeature.swift
//  Boleto
//
//  Created by Sunho on 9/22/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FriendSelectionFeature {
    @ObservableState
    struct State: Equatable {
        var friends = [MemberModel]()
        var searchText: String = ""
        var selectedFriends : [MemberModel]
        var filteredFriends: [MemberModel] {
                  if searchText.isEmpty {
                      return friends
                  }
                  return friends.filter { $0.nickname.contains(searchText) }
              }
        
    }
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case searchFriends
        case tapxmark
        case taperaseField
        case fetchFriend
        case updateResultFriends([MemberModel])
        case toggleFriendSelection(MemberModel)
        case sendFriendId
    }
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.userClient) var userClient
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.searchText):
                return .run { send in
                    await send(.searchFriends)
                        
                }.debounce(id: "SearchDebounce", for: .milliseconds(300), scheduler: DispatchQueue.main)
//                return .none

            case .binding:
                return .none
            case .searchFriends:
//                let filteredFriends = state.friends.filter {$0.contains(state.searchText)}
//                state.resultFriends = filteredFriends
                return .none
            case .tapxmark:
                return .run { _ in
                    await self.dismiss()
                    
                }
            case .taperaseField:
                state.searchText = ""
                return .none
            case .fetchFriend :
//                return .run {send in
//                    let friends = try await userClient.getFriends()
//                    await send(.updateResultFriends(friends))
//                }
                return .none
            case .updateResultFriends(let friends):
                state.friends = friends
                return .none
            case .toggleFriendSelection(let friend):
                if let index = state.selectedFriends.firstIndex(where: { $0.id == friend.id }) {
                                   state.selectedFriends.remove(at: index)
                               } else {
                                   state.selectedFriends.append(friend)
                               }
                    return .none
            case .sendFriendId:
                return .none
            }
            
            return .none
        }
    }
}
