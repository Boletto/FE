//
//  FriendListView.swift
//  Boleto
//
//  Created by Sunho on 10/3/24.
//

import SwiftUI
import ComposableArchitecture
struct FriendListView: View {
    @Bindable var store: StoreOf<MyFriendListsFeature>
    let urlString = "https://boletto.site"
       let message = "선호가 당신과 친구가 되고 싶어요! 링크를 눌러 앱을 설치하고 친구가 되어보세요!"
    var body: some View {
        VStack {
            searchBar
            HStack {
                Button(action: {
                    // 초대 액션 구현
                    store.send(.getFriendLists)
                }) {
                    Label {
                        Text("카카오톡으로 친구 초대")
                            .customTextStyle(.smallBtn)
                            .foregroundStyle(.black)
                    } icon: {
                        Image("kakaotalkIcon")
                            .resizable()
                            .frame(width: 21, height: 21)
                    }
                    .padding(.leading,20)
                    .frame(width: 274,height: 45,alignment: .leading)
                    
                    //                .padding()
                    .background(Color.kakaoColor, in: RoundedRectangle(cornerRadius: 12))
                }
                ShareLink(
                       item: URL(string: urlString)!, // URL을 별도 항목으로 전달
                       subject: Text("친구를 맺어요"),
                       message: Text(message + urlString)
                   ) {
                       Image(systemName: "link")
                           .foregroundStyle(.white)
                           .frame(width: 45, height: 45)
                           .background(Color.gray1, in: RoundedRectangle(cornerRadius: 12))
                   }
            
            }
            .padding(.horizontal,32)
            ScrollView {
                ForEach(store.resultFriend, id: \.id) { result in
                    makeListCell(friend: result)
                }
            }.padding(.horizontal,32)
                .padding(.top,24)
       
            Spacer()
        }.applyBackground(color: .background)
            .alert(store: store.scope(state: \.$alert, action: \.alert))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    Text("친구 추가")
                        .foregroundStyle(.white)
                }
            })
        
        .task {
            store.send(.fetchFriend)
        }
    }
    func makeListCell(friend: AllUser) -> some View {
        VStack {
            HStack(spacing: 0) {
                if let url = friend.imageUrl {
                    URLImageView(urlstring: url, size: CGSize(width: 64, height: 64))
                        .clipShape(Circle())
                        .padding(.trailing,20)
                }
                else {
                    Image("profile")
                        .resizable()
                        .frame(width: 64,height: 64)
                        .clipShape(Circle())
                        .padding(.trailing,20)
                }
                
                Text(friend.nickname)
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .bold))
                    .padding(.trailing,15)
                Text(friend.name ?? "")
                    .foregroundStyle(.gray6)
                Spacer()
                if !friend.isFriend {
                    Button {
                        store.send(.addFriend(friend))
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                    }
                }
         
                
            }
            Spacer()
        }.frame(height: 90)
    }
    private var searchBar: some View {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white)
                    .opacity(0.6)

                TextField("닉네임을 입력하세요", text: $store.searchText)
                    .foregroundStyle(.white)

                Spacer()

                if !store.searchText.isEmpty {
                    Button(action: { store.send(.taperaseField) }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color.gray2)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
            .padding(.top, 40)
        }
}

#Preview {
    FriendListView(store: .init(initialState: MyFriendListsFeature.State(), reducer: {
        MyFriendListsFeature()
    }))
}
