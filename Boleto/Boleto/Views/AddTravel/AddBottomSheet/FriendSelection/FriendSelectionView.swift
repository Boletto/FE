//
//  FriendSelectionView.swift
//  Boleto
//
//  Created by Sunho on 9/22/24.
//

import SwiftUI
import ComposableArchitecture

struct FriendSelectionView: View {
    @Bindable var store: StoreOf<FriendsFeature>
    
    var body: some View {
        VStack {
            headerView
                .padding(.top,16)
                .padding(.bottom,40)
            if store.friends.count > 0 {
                VStack {
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(store.selectedFriends) {friend in
                                makeSelectedFriendCell(friend: friend)
                            }
                        }
                    }.padding(.leading,32)
                    SearchBar(text: $store.searchText, placeholder: "친구를 입력하세요")
                    ScrollView {
                        ForEach(store.filteredFriends) {friend in
                            makeListCell(friend: friend)
                        }
                    }
                    .padding(.horizontal,32)
                    Spacer()
                    Button {
                        store.send(.finishSelectFriend)
                    } label: {
                        Text("완료")
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.main)
                            .clipShape(.capsule)
                    }.padding(.horizontal,16)
                }
            }else {
                VStack {
                    Spacer()
                    Image("friendSelectionImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 157, height: 157)
                    Text("추가 가능한 친구가 없어요\n친구를 BOLETO에 초대해 함께 추억을 공유해보세요!")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray3)
                        .customTextStyle(.normal)
                    Spacer()
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
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.mainColor)
                        }
                    })
                    
                    .padding(.horizontal,32)
                    .padding(.bottom,40)
                    
                }
            }
            
            
        }.applyBackground(color: .background)
            .task {
                store.send(.fetchFriends)
            }
            .sheet(isPresented: $store.openShareLink ) {
                ShareSheet(activityItems: [store.shareUrl,store.shareMessage])
                    .presentationDetents([.medium])
            }
        
    }
    func makeSelectedFriendCell(friend: MemberModel) -> some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                if let url = friend.imageUrl {
                    URLImageView(urlstring: url, size: CGSize(width: 45, height: 45))
                        .clipShape(Circle())
                }
                else {
                    Image("profile")
                        .resizable()
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                }
                Button(action: {
                    store.send(.toggleFriendSelection(friend))
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray2)
                        .font(.system(size: 20))
                        .offset(x:14)
                })

            }
            
            Text(friend.nickname)
                .customTextStyle(.small)
                .foregroundStyle(.white)
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
                    store.send(.toggleFriendSelection(friend))
                } label: {
                    Image(systemName: store.selectedFriends.contains {$0.id == friend.id} ?  "checkmark.square" : "square")
                        .font(.system(size: 18))
                        .foregroundStyle(.gray5)
                }
            }
            Spacer()
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
                    .customTextStyle(.subheadline)
            }
        }
        .foregroundStyle(.white)
    }
    
}


#Preview {
    FriendSelectionView(store: .init(initialState: FriendsFeature.State(friends: [.dummy], selectedFriends: [.dummy], shareUrl: URL("naver.com")!), reducer: {
        FriendsFeature()
    }))
}
