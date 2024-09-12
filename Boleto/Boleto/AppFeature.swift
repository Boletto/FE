//
//  AppFeature.swift
//  Boleto
//
//  Created by Sunho on 9/7/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct AppFeature {
    enum Tab: Equatable {
         case pastTravel
         case mainTravel
         case myPage
     }
    @ObservableState
    struct State {
        var selectedTab: Tab = .mainTravel
        var pastTravel: PastTravelFeature.State = .init()
        var mainTravel: MainTravelFeatrue.State = .init()
        var myPage: MyPageFeature.State = .init()
        
    }
    enum Action {
        case tabSelected(Tab)
        case pastTravel(PastTravelFeature.Action)
        case mainTravel(MainTravelFeatrue.Action)
        case myPage(MyPageFeature.Action)
    }
    var body: some ReducerOf<Self> {
        Scope(state: \.pastTravel, action: \.pastTravel) {
            PastTravelFeature()
        }
        Scope(state: \.mainTravel, action: \.mainTravel) {
            MainTravelFeatrue()
        }
        Scope(state: \.myPage, action: \.myPage) {
            MyPageFeature()
        }
        Reduce { state, action in
            switch action {
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
            case .pastTravel:
                return .none
            case .mainTravel:
                return .none
            case .myPage:
                return .none
            }
            
        }
    }
    
}
