//
//  FriendSelectionView.swift
//  Boleto
//
//  Created by Sunho on 9/22/24.
//

import SwiftUI
import ComposableArchitecture

struct FriendSelectionView: View {
    @Bindable var store: StoreOf<FriendSelectionFeature>
    var body: some View {
        VStack {
            headerView
                .padding(.top,16)
            if store.friends.count > 0 {
                VStack {
                    searchBar
                    ScrollView {
                        ForEach(store.filteredFriends) {friend in
                            makeListCell(friend: friend)
                        }
                    }
                    
                }
            }else {
                VStack {
                    Image("friendSelectionImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(EdgeInsets(top: 188, leading: 118, bottom: 36, trailing: 118))
                    Text("추가 가능한 친구가 없어요\n친구를 BOLETO에 초대해 함께 추억을 공유해보세요!")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray3)
                        .customTextStyle(.body1)
                    Spacer()
                        .padding(.top, 12)
                }
            }
            Spacer()
            Button {
                store.send(.sendFriendId)
            } label: {
                Text("완료")
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.main)
                    .clipShape(.capsule)
            }.padding(.horizontal,16)
            
        }.applyBackground(color: .background)
            .task {
                store.send(.fetchFriend)
            }
        
    }
    func makeListCell(friend: FriendDummy) -> some View {
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
                Text(friend.name ?? "")
                    .foregroundStyle(.white)
                    .opacity(0.6)
                    .customTextStyle(.body1)
                Spacer()
                Button {
                    store.send(.toggleFriendSelection(friend))
                } label: {
                    Image(systemName: store.selectedFriends.contains(where: { $0.id == friend.id }) ? "checkmark.square" : "square")
                        .font(.system(size: 24))
                        .foregroundStyle(store.selectedFriends.contains(where: { $0.id == friend.id }) ? Color.main : .white)    
                }
                
                
            }.padding(.horizontal,32)
        Divider()
                .foregroundStyle(.gray2)
        }.frame(height: 90)
    }
    private var headerView: some View {
        ZStack {
            HStack {
                Button(action: {
                    store.send(.tapxmark)
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 21, height: 21)
                }
                Spacer()
            }
            .padding(.leading, 32)
            
            HStack {
                Text("함께하는 친구")
                    .customTextStyle(.pageTitle)
            }
        }
        .foregroundStyle(.white)
    }
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white)
                .opacity(0.6)
            
            TextField("친구를 입력하세요", text: $store.searchText)
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

//#Preview {
//    FriendSelectionView(store: .init(initialState: FriendSelectionFeature.State(), reducer: {
//        FriendSelectionFeature()
//    }))
//}
