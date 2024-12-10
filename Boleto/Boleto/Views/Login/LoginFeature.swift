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
        @Shared(.appStorage("profile")) var profile: String = ""
        @Shared(.appStorage("nickname")) var nickname: String = ""
        @Shared(.appStorage("name")) var name: String = ""
    }
    
    enum Action {
        case tapKakaoSigin
        case postLoginInfo(LoginUserRequest)
        case postAppleLoginToken(String)
        case loginSuccess(User)
        case moveToAgreement
        case loginFailure(Error)
    }
    @Dependency(\.kakaoLoginClient) var kakaoLoginClient
    @Dependency(\.accountClient) var accountClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
  
            case .tapKakaoSigin:
                return .run { send in
                    do {
                        let _ = try await kakaoLoginClient.signin()
                        let user = try await kakaoLoginClient.fetchUserInfo()
                        await send(.postLoginInfo(user))
                    }
                    catch {
                        await send(.loginFailure(error))
                    }
                }
            case .moveToAgreement:
                return .none
            case .postLoginInfo(let user):
                return .run { send in
                    do {
                        let user = try await accountClient.postLogi(user)
                        if let user = user {
                            await send(.loginSuccess(user))
                        } else {
                            await send(.moveToAgreement)
                        }
            
                    } catch {
                        await send(.loginFailure(error))
                    }
                }
            case .postAppleLoginToken(let identityToken):
                return .run { send in
                    do {
                        let user = try await accountClient.postAppleLogin(AppleLoginRequest(identityToken: identityToken))
                        if let user = user {
                            await send(.loginSuccess(user))
                        } else {
                            await send(.moveToAgreement)
                        }
                    }catch {
                        await send(.loginFailure(error))
                    }
                }
               
            case .loginSuccess(let user):
                state.isLogin = true
                state.name = user.name
                state.nickname = user.nickName
                return .none
            case .loginFailure(let error ):
                print(error)
                return .none
            }
        }
    }
}
