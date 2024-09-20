//
//  KakaoLoginClient.swift
//  Boleto
//
//  Created by Sunho on 9/21/24.
//

import Foundation
import KakaoSDKAuth
import ComposableArchitecture
import KakaoSDKUser

@DependencyClient
struct KakaoLoginClient{
    var signin: @Sendable () async throws -> OAuthToken
    var fetchUserInfo: @Sendable () async throws -> KakaoUser
    
}
struct KakaoUser: Equatable {
    let id: Int64
    let nickname: String
}
extension KakaoLoginClient: DependencyKey {
    static var liveValue : Self =  {
        return Self(
            signin:    {
                try await withCheckedThrowingContinuation { continuation in
                    if UserApi.isKakaoTalkLoginAvailable() {
                        UserApi.shared.loginWithKakaoTalk { (oauthToken, err) in
                            if let error = err {
                                continuation.resume(throwing: error)
                            } else if let token = oauthToken {
                                continuation.resume(returning: token)
                            }
                        }
                    } else {
                        UserApi.shared.loginWithKakaoAccount { (oauthtoken, error) in
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else if let token = oauthtoken {
                                continuation.resume(returning: token)
                            }
                        }
                    }
                }
            },fetchUserInfo: {
                try await withCheckedThrowingContinuation { continuation in
                    UserApi.shared.me { user, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let user = user {
                            let kakaoUser = KakaoUser(id: user.id ?? 0, nickname: user.kakaoAccount?.profile?.nickname ?? "")
                            continuation.resume(returning: kakaoUser)
                        }
                    }
                }
            })
    }()
}
extension DependencyValues {
    var kakaoLoginClient: KakaoLoginClient {
        get { self[KakaoLoginClient.self] }
        set { self[KakaoLoginClient.self] = newValue }
    }
}
