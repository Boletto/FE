//
//  MyPageView.swift
//  Boleto
//
//  Created by Sunho on 9/11/24.
//

import SwiftUI
import ComposableArchitecture
struct MyPageView: View {
    @Bindable var store: StoreOf<MyPageFeature>
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                myProfileTicketView
                    .padding(.top, 20)
                myTravelMemoryViews
                settingSectionView
            }.padding(.horizontal,32)
        }
        .alert($store.scope(state: \.alert, action: \.alert))

            .fullScreenCover(isPresented: $store.showOutMember) {
                OutMemberView(store: store.scope(state: \.outMemberState, action: \.outMemberAction))
                  }
    }
    var myProfileTicketView: some View {
        VStack(alignment: .leading,spacing: 15) {
            Text("나의 프로필")
                .foregroundStyle(.white)
                .customTextStyle(.subheadline)
            ZStack(alignment: .topLeading) {
                Image("settinginfo")
                    .resizable()
                HStack(spacing: 15) {
                    Group {
                        if store.profile != "" {
                            AsyncImageView(urlString: store.profile, imagetype: .image)
                                .frame(width: 60,height: 60)
                                .clipShape(Circle())
                        } else {
                            Image("defaultprofile")
                                .resizable()
                                .clipShape(Circle())
                        }
                    }.frame(width: 60, height: 60)
     
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 14) {
                            Text(store.nickname)
                                .customTextStyle(.title)
                            Image(systemName: "chevron.right")
                        }
                        Text(store.name)
                            .customTextStyle(.body1)
                    }.onTapGesture {
                        store.send(.profileTapped)
                    }
                    Spacer()
                }
                .padding(.top,30)
                .padding(.leading,21)
            }.frame(maxWidth: .infinity)
            .frame(height: 180)
        }
    }
    var myTravelMemoryViews: some View {
        VStack(alignment: .leading) {
            Text("여행 수첩")
                .foregroundStyle(.white)
                .customTextStyle(.subheadline)
            HStack(spacing: 15) {
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray1)
                        .scaledToFit()
                    Image("stamp")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140,height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .overlay {
                    VStack {
                        HStack {
                            Text("나의 여행 네컷")
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        Spacer() // Pushes the content to the top-left
                    }
                    .padding(.top, 16)
                    .padding(.leading, 15)
                }
                .onTapGesture {
                    store.send(.travelPhotosTapped)
                }
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray1)
                        .scaledToFit()
                    Image("stamp1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140,height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .overlay {
                    VStack {
                        HStack {
                            Text("나의 스티커")
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        Spacer() // Pushes the content to the top-left
                    }
                    .padding(.top, 16)
                    .padding(.leading, 15)
                }
                .onTapGesture {
                    store.send(.stickersTapped)
                }
            }
            
        }
    }
    var settingSectionView: some View {
        VStack(spacing: 15) {
            makeSectionView(title: "함께하는 여행") {
                makeListView(text: "친구 목록")
                    .onTapGesture {
                        store.send(.friendListTapped)
                    }
                makeListView(text: "초대받은 여행")
                    .onTapGesture {
                        store.send(.invitedTravelsTapped)
                    }
            }
            makeSectionView(title: "설정") {
//                makeToggleView(text: "모든 알림", toggle: $store.notiAlert)
                makeListView(text: "모든 알림")
                    .onTapGesture {
                        store.send(.tapNotiManage)
                    }
            }
            makeSectionView(title: "개인정보 보호") {
                makeListView(text: "위치 정보 제공 동의")
                    .onTapGesture {
                        store.send(.tapLocationAuthor)
                    }
             
            }
            
            
            makeSectionView(title:"계정") {
                makeListView(text: "로그아웃")
                    .onTapGesture {
                        store.send(.logoutTapped)
                    }
                makeListView(text: "회원 탈퇴")
                    .onTapGesture {
                        store.send(.toggleOutMemberView)
                    }
            }
        }
    }
    @ViewBuilder
    func makeSectionView(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .foregroundStyle(.white)
                    .customTextStyle(.subheadline)
                    .padding(.bottom,5)
                content()
            }
    }
    func makeListView(text: String) -> some View {
        HStack {
            Text(text)
                .foregroundStyle(.white)
                .customTextStyle(.body1)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.white)
        }
        .padding(.vertical,11)
        .padding(.horizontal,15)
        .frame(height: 45)
        .background(RoundedRectangle(cornerRadius: 5).fill(.gray1))
    }
    func makeToggleView(text: String, toggle: Binding<Bool>) -> some View {
        HStack {
            Text(text)
                .foregroundStyle(.white)
                .customTextStyle(.body1)
            Spacer()
            Toggle("", isOn:toggle).tint(.main)
                .frame(width: 46,height: 31)
        }
        .padding(.horizontal,15)
        .frame(height: 45)
        .background(RoundedRectangle(cornerRadius: 5).fill(.gray1))
    }
}

#Preview {
    MyPageView(store: .init(initialState: MyPageFeature.State(), reducer: {
        MyPageFeature()
    }))
}
