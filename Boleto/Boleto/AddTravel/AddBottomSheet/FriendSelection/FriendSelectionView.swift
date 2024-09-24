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
            if store.friends.count > 0 {
                VStack {
                   searchBar
                    HStack{
                        HStack(spacing: 0) {
                            Image("kakaotalkIcon")
                                .padding(.leading,20)
                            Text("카카오톡으로 친구 초대")
                                .customTextStyle(.small)
                                .padding(.leading, 16)
                            Spacer()
                        }.frame(height: 45)     .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.kakaoColor))
//                        .padding(.trailing,10)
                        Image(systemName:"link")
                            .foregroundStyle(.white)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray1).frame(width: 45,height: 45))
                            .layoutPriority(1)
                    }.padding(.horizontal,32)
                    
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
                    Button {
                        
                    } label: {
                        ZStack {
                            HStack {
                                Image("kakaotalkIcon")
                                    .resizable()
                                    .frame(width: 20,height: 20)
                                Spacer()
                            }.padding(.leading,28)
                            Text("카카오톡으로 친구 초대")
                                .foregroundStyle(.black)
                                .customTextStyle(.small)
                        }.frame(width: 329, height: 45)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.kakaoColor))
                    }
                    Button {
                        
                    } label: {
                        ZStack {
                            HStack {
                                Image(systemName: "link")
                                    .resizable()
                                    .frame(width: 20,height: 20)
                                    .foregroundStyle(.gray6)
                                Spacer()
                            }.padding(.leading,28)
                            Text("초대 링크 복사하기")
                                .foregroundStyle(.white)
                                .customTextStyle(.small)
                        }.frame(width: 329, height: 45)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray1))
                    }
                    .padding(.top, 12)
                }
            }
        }.applyBackground(color: .background)
        
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

#Preview {
    FriendSelectionView(store: .init(initialState: FriendSelectionFeature.State(), reducer: {
        FriendSelectionFeature()
    }))
}
