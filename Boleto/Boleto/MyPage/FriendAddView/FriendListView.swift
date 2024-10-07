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
    var body: some View {
        VStack {
            searchBar
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
