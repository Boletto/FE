//
//  EditProfileView.swift
//  Boleto
//
//  Created by Sunho on 9/12/24.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI
struct EditProfileView: View {
    @Bindable var store: StoreOf<MyProfileFeature>
    var body: some View {
        VStack {profileImageView
                
            
            .padding(.bottom, 56)
            VStack(alignment: .leading, spacing: 10) {
                Text("닉네임")
                    .customTextStyle(.subheadline)
                    .foregroundColor(.white)
                TextField("닉네임을 입력하세요", text: $store.inputnickName)
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
                TextField("닉네임을 입력하세요", text: $store.inputname)
                    .foregroundStyle(.white)
                    .customTextStyle(.body1)
                Divider()
                    .frame(height: 1)
                    .background(.gray2)
            }
            Spacer()
            Button(action: {}, label: {
                Text("저장")
                    .customTextStyle(.normal)
                    .foregroundStyle(.gray1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(RoundedRectangle(cornerRadius: 30).fill(.main))
                
            }).padding(.bottom,30)
            
        }
        .padding(.top, 40)
        .padding(.horizontal, 32)
        .applyBackground(color: .background)
        .navigationBarBackButtonHidden()
        .photosPicker(isPresented: $store.isImagePickerPresented, selection: $store.selectedItem)
        .confirmationDialog(store: store.scope(state: \.$confirmationDialog, action: \.confirmationDialog))
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("프로필 편집")
                    .foregroundStyle(.white)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {store.send(.backbuttonTapped)}, label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(.white)
                })
            }
        }
        .onAppear {
            store.send(.selectMode(mode: .edit))
        }
    }
    var profileImageView: some View {
        Button {
            store.send(.tapProfile)
        } label: {
            ZStack(alignment: .bottomTrailing) {
                if let profileImage = store.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 148,height: 148)
                        .clipShape(Circle())
                } else {
                    Image("profile")
                        .resizable()
                        .frame(width: 148,height: 148)
                }
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
            
        }
    }
}

#Preview {
    EditProfileView(store: .init(initialState: MyProfileFeature.State(), reducer: {
        MyProfileFeature()
    }))
}
