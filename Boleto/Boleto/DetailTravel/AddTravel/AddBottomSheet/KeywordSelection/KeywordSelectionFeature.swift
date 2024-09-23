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
//        let keywords = ["봉사", "시골여행", "럭셔리", "순례", "워크숍", "나홀로", "졸업여행", "휴양", "뚜벅이", "모험", "덕직", "유적지", "쇼핑", "가족", "느린여행", "호캉스", "운동", "커플", "액티비티", "관광", "식도락"]
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
