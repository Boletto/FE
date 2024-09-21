//
//  AppleLoginClient.swift
//  Boleto
//
//  Created by Sunho on 9/20/24.
//

import Foundation
import AuthenticationServices
import ComposableArchitecture

@DependencyClient
struct AppleLoginClient {
    var signIn: @Sendable () async throws ->  ASAuthorization
}

extension AppleLoginClient: DependencyKey {
    static var liveValue: Self  = {
        return Self(
            signIn: {
                try await withCheckedThrowingContinuation { continuation in
                    let request = ASAuthorizationAppleIDProvider().createRequest()
                    request.requestedScopes = [.fullName,.email]
                    let controller = ASAuthorizationController(authorizationRequests: [request])
   
                    let delegate = SignInWithAppleDelegate(continuation: continuation)
                    controller.delegate = delegate
                    controller.performRequests()
                }
            }
        )
    }()
}
extension DependencyValues {
    var appleLoginClient: AppleLoginClient {
        get { self[AppleLoginClient.self] }
        set { self[AppleLoginClient.self] = newValue }
    }
}
class SignInWithAppleDelegate: NSObject, ASAuthorizationControllerDelegate {
    let continuation: CheckedContinuation<ASAuthorization, Error>
    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
        super.init() 
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation.resume(returning: authorization)// 로그인 성공 시 authorization 객체를 반환하면서 비동기 흐름 재개
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        continuation.resume(throwing: error)
    }
}
