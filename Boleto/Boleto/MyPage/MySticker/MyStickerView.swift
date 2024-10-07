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
    @Query(FetchDescriptor<BadgeData>()) var badges: [BadgeData]
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Group {
                        Text("\(badges.filter{$0.isCollected}.count)" ).foregroundStyle(.main) + Text("/12개").foregroundStyle(.white)
                    }
                        .customTextStyle(.title)
                    
                    Text("여행을 통해 명소 스티커를 모아보세요.")
                        .foregroundStyle(.gray5)
                        .customTextStyle(.body1)
                       
                }
                Spacer()
            }.padding(.top,48)
                .padding(.bottom, 16)
            stickerGridView
                .padding(.bottom,85)
        }.padding(.horizontal,32).applyBackground(color: .background)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("나의 스티커")
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.white)
                    })
                }
            }
        
    }
    var stickerGridView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray1)
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()),GridItem(.flexible())], content: {
                    ForEach(badges) { badge in
                        VStack(spacing: 14) {
                            Group {
                                Image(badge.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 78,height: 78)
                                Text(badge.name)
                                    .customTextStyle(.small)
                                    .foregroundStyle(.white)
                            }
                            //                        .foregroundStyle(badge.isCollected ? .white : .gray4)
                            .opacity(badge.isCollected ? 1.0 : 0.3)
                            //
                        }.padding(.top, 27)
                    }
                })
            }.padding(.horizontal,16)
                .padding(.bottom, 35)
        }
    }
    
}
//#Preview { @MainActor in
//    MyStickerView(store: .init(initialState: MyStickerFeature.State(), reducer: {
//        MyStickerFeature()
//    }))
//        .modelContainer(Preview().container) // 모델 컨테이너 설정
//    
//}
