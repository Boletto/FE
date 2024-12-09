//
//  FriendListView.swift
//  Boleto
//
//  Created by Sunho on 10/3/24.
//

import SwiftUI
import ComposableArchitecture
struct FriendListView: View {
    @Bindable var store: StoreOf<FriendsFeature>
    @Environment(\.dismiss) private var dismiss // DismissAction
    var body: some View {
        VStack {
            SearchBar(text: $store.searchText, placeholder: "찾으시려는 닉네임을 입력하세요")
                .padding(.top, 40)
            Button(action: {
                store.send(.shareLinkTapped)
            }, label: {
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 46)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.mainColor)
                }
            })
             .padding(.horizontal,32)
            ScrollView {
                LazyVStack {
                    ForEach(store.filteredFriends, id: \.id) { model in
                                       makeListCell(friend: model)
                                   }
                }
                
            }.padding(.horizontal,32)
                .padding(.top,20)
            
            Spacer()
        }
            .alert(store: store.scope(state: \.$alert, action: \.alert))
      
            .task {
                store.send(.fetchFriends)
            }
            .sheet(isPresented: $store.openShareLink ) {
                ShareSheet(activityItems: [store.shareUrl,store.shareMessage])
                    .presentationDetents([.medium])
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
                    Image("defaultprofile")
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

//#Preview {
//    FriendListView(store: .init(initialState: MyFriendListsFeature.State(friendLists: [.dummy]), reducer: {
//        MyFriendListsFeature()
//    }))
//}
