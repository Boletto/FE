//
//  LoginView.swift
//  Boleto
//
//  Created by Sunho on 9/20/24.
//

import SwiftUI
import ComposableArchitecture
import AuthenticationServices
struct LoginView: View {
    @Bindable var store: StoreOf<LoginFeature>
    var body: some View {
        VStack(spacing: 0) {
            Image("logo")
                .resizable()
                .aspectRatio(3.7,contentMode: .fit)
                .padding(.horizontal,77)
                .padding(.top, 293)
                .padding(.bottom,11)
            Text("여행을 한 번 더 볼래, 또?")
                .foregroundStyle(.white)
                .font(.system(size: 17, weight: .regular))
            Spacer()
            Button {
                store.send(.tapKakaoSigin)
            } label: {
                Image("kakaoLoginButton")
                    .resizable()
                    .frame(height: 56)
                    .padding(.horizontal,16)
            }
            .padding(.bottom,13)
            Image("appleLogin")
                .resizable()
                .frame(height: 56)
                .padding(.horizontal, 16)
                .overlay {
                    SignInWithAppleButton(.signIn,
                                          onRequest: {request in
                        request.requestedScopes = [.fullName,.email]},
                                          onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            switch authResults.credential{
                            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                let identityToken = String(data: appleIDCredential.identityToken!, encoding: .utf8)
                                store.send(.postAppleLoginToken(identityToken!))
                            default:
                                break
                            }
                        case .failure(let failure):
                            print(failure)
                        }
                    }
                    ).blendMode(.overlay)
                    .padding(.horizontal, 24)
                }
              
            
            
        }.applyBackground(color: .main)
    }
}

#Preview {
    LoginView(store: .init(initialState: LoginFeature.State(), reducer: {
        LoginFeature()
    }))
}
