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
        VStack {
            Image("logo")
                .resizable()
                .aspectRatio(3.7,contentMode: .fit)
                .padding(.horizontal,77)
                .padding(.top, 293)
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

   
            Image("appleLogin")
                .overlay {
                    SignInWithAppleButton(.signIn,
                                          onRequest: {request in
                        request.requestedScopes = [.fullName,.email]},
                                          onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            switch authResults.credential{
                                                 case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                                    // 계정 정보 가져오기
                          
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
                        .padding(.all, 8)
                }
                .frame(height: 56)
                .padding(.horizontal, 16)
     
                
        }.applyBackground(color: .main)
    }
}

#Preview {
    LoginView(store: .init(initialState: LoginFeature.State(), reducer: {
        LoginFeature()
    }))
}
