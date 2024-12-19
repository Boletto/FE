//
//  LoginFeature.swift
//  Boleto
//
//  Created by Sunho on 9/20/24.
//

import Foundation
import ComposableArchitecture
import KakaoSDKAuth
import KakaoSDKUser

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
    @Dependency(\.accountClient) var accountClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
  
            case .tapKakaoSigin:
                return .run { send in
                    do {
                        let token = try await kakaoSignin()
                        let user = try await fetchKakaoUserInfo()
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
    private func kakaoSignin() async throws -> OAuthToken {
           try await withCheckedThrowingContinuation { continuation in
               DispatchQueue.main.async {
                   if UserApi.isKakaoTalkLoginAvailable() {
                       UserApi.shared.loginWithKakaoTalk { token, error in
                           if let error = error {
                               continuation.resume(throwing: error)
                           } else if let token = token {
                               continuation.resume(returning: token)
                           }
                       }
                   } else {
                       UserApi.shared.loginWithKakaoAccount { token, error in
                           if let error = error {
                               continuation.resume(throwing: error)
                           } else if let token = token {
                               continuation.resume(returning: token)
                           }
                       }
                   }
               }
           }
       }
    
    private func fetchKakaoUserInfo() async throws -> LoginUserRequest {
         try await withCheckedThrowingContinuation { continuation in
             DispatchQueue.main.async {
                 UserApi.shared.me { user, error in
                     if let error = error {
                         continuation.resume(throwing: error)
                     } else if let user = user {
                         let userRequest = LoginUserRequest(
                             serialId: String(user.id ?? 0),
                             provider: "KAKAO",
                             nickname: user.kakaoAccount?.profile?.nickname ?? ""
                         )
                         continuation.resume(returning: userRequest)
                     }
                 }
             }
         }
     }
}
