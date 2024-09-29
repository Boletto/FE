//
//  AddProfileView.swift
//  Boleto
//
//  Created by Sunho on 9/29/24.
//

import SwiftUI
import ComposableArchitecture
struct AddProfileView: View {
    @Bindable var store: StoreOf<MyProfileFeature>
    var body: some View {
        VStack {
            Text("여행을 위한 프로필을 생성해주세요")
                .foregroundStyle(.gray6)
                .customTextStyle(.title)
                .padding(EdgeInsets(top: 41, leading: 0, bottom: 0, trailing: 35))
            ZStack (alignment: .bottomTrailing) {
                Image("profile")
                    .resizable()
                    .frame(width: 148,height: 148)
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 38,height: 38)
                    Image("PencilSimple")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 21,height: 21)
                        .foregroundStyle(.main)
                    
                }
            }
            .padding(.bottom, 56)
            VStack(alignment: .leading, spacing: 10) {
                Text("닉네임")
                    .customTextStyle(.subheadline)
                    .foregroundColor(.white)
                TextField("닉네임을 입력하세요", text: $store.nickName)
                    .foregroundStyle(.white)
                    .customTextStyle(.body1)
                //                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Divider()
                    .frame(height: 1)
                    .background(.gray2)
                    .padding(.bottom, 25)
                Text("이름")
                    .customTextStyle(.subheadline)
                    .foregroundColor(.white)
                TextField("닉네임을 입력하세요", text: $store.name)
                    .foregroundStyle(.white)
                    .customTextStyle(.body1)
                Divider()
                    .frame(height: 1)
                    .background(.gray2)
            }
            Spacer()
            Button(action: {}, label: {
                Text("프로필 생성")
                    .customTextStyle(.normal)
                    .foregroundStyle(.gray1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(RoundedRectangle(cornerRadius: 30).fill(.main))
                
            }).padding(.bottom,30)
        }
        .padding(.horizontal, 32)
    }
}
