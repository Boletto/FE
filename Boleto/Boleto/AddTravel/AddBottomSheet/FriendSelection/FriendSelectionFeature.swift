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
        var friends = ["dkssudgktp","dijf"]
        var searchText: String = ""
        var resultFriends = [String]()
        
    }
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case searchFriends
        case tapxmark
        case taperaseField
        
    }
    @Dependency(\.dismiss) var dismiss
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
                let filteredFriends = state.friends.filter {$0.contains(state.searchText)}
                state.resultFriends = filteredFriends
                return .none
            case .tapxmark:
                return .run { _ in
                    await self.dismiss()
                    
                }
            case .taperaseField:
                state.searchText = ""
                return .none
            }
            return .none
        }
    }
}
