//
//  LoginFeature.swift
//  Boleto
//
//  Created by Sunho on 9/20/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct LoginFeature {
    @ObservableState
    struct State {
        @Shared(.appStorage("isLogin")) var isLogin: Bool = false

    }
    
    enum Action {
        case tapAppleSignin
        case tapKakaoSigin
        case loginSuccess
        case loginFailure(Error)
    }
    @Dependency(\.appleLoginClient) var appleLoginClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .tapAppleSignin:
                return .run { send in
                    do {
                        _ =       try await appleLoginClient.signIn()
                        await send(.loginSuccess)
                    } catch {
                        await send(.loginFailure(error))
                    }
              
                }
            case .tapKakaoSigin:
                return .none
            case .loginSuccess:
                state.isLogin = true
                print("HIlogin")
                return .none
            case .loginFailure(let error ):
                print(error)
                return .none
            }
        }
    }
}
