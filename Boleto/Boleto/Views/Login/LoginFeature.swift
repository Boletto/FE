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
        @Shared(.appStorage("userID")) var userID: Int = 0
        @Shared(.appStorage("profile")) var profile: String = ""
        @Shared(.appStorage("nickname")) var nickname: String = ""
        @Shared(.appStorage("name")) var name: String = ""
    }
    
    enum Action {
        case tapKakaoSigin
        case postLoginInfo(LoginUserRequest)
        case postAppleLoginToken(String)
        case loginSuccess(User)
        case moveToProfile
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
                        let token = try await kakaoLoginClient.signin()
                        let user = try await kakaoLoginClient.fetchUserInfo()
                        print(user)
                        await send(.postLoginInfo(user))
                    }
                    catch {
                        await send(.loginFailure(error))
                    }
                }
            case .moveToProfile:
                return .none
            case .postLoginInfo(let user):
                return .run { send in
                    do {
                        let user = try await accountClient.postLogi(user)
//                        print(temp)
                        if let user = user {
                            await send(.loginSuccess(user))
                        } else {
                            await send(.moveToProfile)
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
                            await send(.moveToProfile)
                        }
                    }catch {
                        await send(.loginFailure(error))
                    }
                }
               
            case .loginSuccess(let user):
                state.isLogin = true
                state.userID = user.userID
                state.name = user.name
                state.nickname = user.nickName
//                state.profile = user.profileImage
                return .none
            case .loginFailure(let error ):
                print(error)
                return .none
            }
        }
    }
}
