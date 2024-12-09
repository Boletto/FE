//
//  EditProfileView.swift
//  Boleto
//
//  Created by Sunho on 9/12/24.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher
import PhotosUI
struct EditProfileView: View {
    @Bindable var store: StoreOf<MyProfileFeature>
    var body: some View {
        VStack {
            if store.mode == .add {
                Text("여행을 위한 프로필을 생성해주세요")
                    .foregroundStyle(.gray6)
                    .customTextStyle(.title)
                    .padding(EdgeInsets(top: 40, leading: 0, bottom: 0, trailing: 0))
            }
            profileImageView
            .padding(.top,40)
            .padding(.bottom, 56)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("닉네임")
                    .customTextStyle(.subheadline)
                    .foregroundColor(.white)
                TextField("닉네임을 입력하세요", text: $store.inputnickName)
                    .foregroundStyle(.white)
                    .customTextStyle(.body1)
                
                Divider()
                    .frame(height: 1)
                    .background(.gray2)
                    .padding(.bottom, 25)
                Text("이름")
                    .customTextStyle(.subheadline)
                    .foregroundColor(.white)
                TextField("닉네임을 입력하세요", text: $store.inputname)
                    .foregroundStyle(.white)
                    .customTextStyle(.body1)
                Divider()
                    .frame(height: 1)
                    .background(.gray2)
            }
            Spacer()
            Button(action: {store.send(.saveProfile)}, label: {
                Text(store.mode == .add ? "프로필 생성" : "저장")
                    .customTextStyle(.normal)
                    .foregroundStyle(.gray1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(RoundedRectangle(cornerRadius: 30).fill(.main))
            }).padding(.bottom,30)
        }
        .padding(.horizontal, 32)
        .photosPicker(isPresented: $store.isImagePickerPresented, selection: $store.selectedItem)
        .confirmationDialog(store: store.scope(state: \.$confirmationDialog, action: \.confirmationDialog))
       .onAppear {
            store.send(.loadUserInfo)
        }
    }
    var profileImageView: some View {
        Button {
            store.send(.tapProfile)
        } label: {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if store.isDefaultImageSelected {
                        Image("defaultprofile")
                            .resizable()
                    } else if let profileImage = store.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                    } else if let urlString = URL(string: store.image) {
                        KFImage.url(urlString)
                            .resizable()
                    } else {
                        Image("defaultprofile")
                            .resizable()
                    }
                }
                .scaledToFill()
                .frame(width: 148, height: 148)
                .clipShape(Circle())
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 38, height: 38)
                    Image("PencilSimple")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 21, height: 21)
                        .foregroundStyle(.main)
                }
            }
        }
    }
}

//#Preview {
//    EditProfileView(store: .init(initialState: MyProfileFeature.State(), reducer: {
//        MyProfileFeature()
//    }))
//}
