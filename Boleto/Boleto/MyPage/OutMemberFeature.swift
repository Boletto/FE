//
//  OutMemberFeature.swift
//  Boleto
//
//  Created by Sunho on 9/28/24.
//

import ComposableArchitecture
import SwiftUI
@Reducer
struct OutMemberFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var alert: AlertState<Action.Alert>?
    }
    enum Action {
        case alert(PresentationAction<Alert>)
        case tapCloseButton
        case outMemberTapped
        enum Alert {
            case doEraseMember
        }
    }
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce {state ,action in
            switch action {
            case .tapCloseButton:
                return .run {send in
                    await dismiss()
                }
            case .outMemberTapped:
                state.alert = AlertState {
                    TextState("정말 탈퇴하시겠어요??")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                    ButtonState(action: .doEraseMember) {
                        TextState("계정삭제")
                    }
                }
                return .none
            default:
                return .none
            }
        }.ifLet(\.$alert, action: \.alert)
    }
}
