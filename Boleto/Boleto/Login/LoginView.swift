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
            Image("appleLogin")
                .overlay {
                    SignInWithAppleButton(.signIn,
                                          onRequest: {_ in},
                                          onCompletion: { _ in store.send(.tapAppleSignin)
                        
                        
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
