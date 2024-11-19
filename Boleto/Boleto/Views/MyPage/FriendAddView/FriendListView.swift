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
    let baseUrlString = "https://boletto.site"
    let message = "선호가 당신과 친구가 되고 싶어요! 링크를 눌러 앱을 설치하고 친구가 되어보세요!"
    var shareUrl: URL {
        URL(string: baseUrlString + "/" + store.shareCode)!
    }
    var body: some View {
        VStack {
            SearchBar(text: $store.searchText, placeholder: "찾으시려는 닉네임을 입력하세요")
            ShareLink(
                item: shareUrl, // URL을 별도 항목으로 전달
                subject: Text("친구를 맺어요"),
                message: Text(message + "\n" + shareUrl.absoluteString)
            ) {
                Label {
                    Text("친구 추가 링크 공유하기")
                        .customTextStyle(.smallBtn)
                        .foregroundStyle(.gray1)
                } icon: {
                    Image(systemName: "link")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.gray1)
                        .padding(.leading, 24)
                }
                .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
                .frame(height: 46)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.mainColor)
                }
                
            } 
            .padding(.horizontal,32)
            .onAppear {
                store.send(.shareLinkTapped)
            }

            
            ScrollView {
                LazyVStack {
                    ForEach(store.searchText.isEmpty ? store.friendLists : store.searchLists, id: \.id) { model in
                                       makeListCell(friend: model)
                                   }
                }
                
            }.padding(.horizontal,32)
                .padding(.top,20)
            
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
                store.send(.getFriendLists)
            }
    }
    func makeListCell(friend: MemberModel) -> some View {
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
                    .font(.system(size: 17, weight: .regular))
                    .padding(.trailing,15)
                Text(friend.name    )
                    .foregroundStyle(.gray5)
                    .customTextStyle(.normal)
                Spacer()
                Button {
                    store.send(.tapDeleteFriend(friend))
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 18))
                        .foregroundStyle(.gray5)
                }
            }
            Spacer()
        }.frame(height: 90)
    }
  
}

#Preview {
    FriendListView(store: .init(initialState: MyFriendListsFeature.State(friendLists: [.dummy]), reducer: {
        MyFriendListsFeature()
    }))
}
