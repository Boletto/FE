//
//  MyStickerView.swift
//  Boleto
//
//  Created by Sunho on 9/12/24.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct MyStickerView: View {
//    @Query var badges: [Badge]
    @Bindable var store: StoreOf<MyStickerFeature>
        @Query var badges: [BadgeData   ]
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Group {
                        Text("\(badges.filter{$0.isCollected}.count)" ).foregroundStyle(.main) + Text("/15개").foregroundStyle(.white)
                    }
                        .customTextStyle(.title)
                    
                    Text("여행을 통해 명소 스티커를 모아보세요.")
                        .customTextStyle(.body1)
                        .foregroundStyle(.gray5)
                }
                Spacer()
            }.padding(.top,24)
            stickerGridView
        }.padding(.horizontal,32).applyBackground(color: .background)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("나의 스티커")
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {store.send(.backbuttonTapped)}, label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.white)
                    })
                }
            }
        
    }
    var stickerGridView: some View {
//        ScrollView {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray1)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()),GridItem(.flexible())], content: {
                ForEach(badges) { badge in
                    VStack(spacing: 8) {
                        Group {
                            Image(badge.imageName)
                                .resizable()
                                .frame(width: 78,height: 78)
                            Text(badge.name)
                                .customTextStyle(.subheadline)
                        }.foregroundStyle(badge.isCollected ? .white : .gray4)
                    }
                }
            })
        }
    }
    
}
#Preview { @MainActor in
    MyStickerView(store: .init(initialState: MyStickerFeature.State(), reducer: {
        MyStickerFeature()
    }))
        .modelContainer(Preview().container) // 모델 컨테이너 설정
    
}
