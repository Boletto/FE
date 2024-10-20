//
//  KeywordSelectionFeature.swift
//  Boleto
//
//  Created by Sunho on 9/3/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct KeywordSelectionFeature {
    @ObservableState
    struct State: Equatable {
           var selectedKeywords: [Keywords] = []
           var showWarning: Bool = false
    }
    
    enum Action {
        case tapkeyword(Keywords)
        case tapSubmit
    }
    var body: some ReducerOf<Self> { 
        Reduce {state, action in
            switch action {
            case .tapkeyword(let keyword):
                if state.selectedKeywords.contains(keyword) {
                    state.selectedKeywords.removeAll {$0 == keyword}
                } else {
                    if state.selectedKeywords.count < 3 {
                        state.selectedKeywords.append(keyword)
                        state.showWarning = false
                    } else {
                        state.showWarning = true
                    }
                }
                return .none
            case .tapSubmit:
                return .none
            }
        }
    }
}
