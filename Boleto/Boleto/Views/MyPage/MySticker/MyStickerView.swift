//
//  MyStickerView.swift
//  Boleto
//
//  Created by Sunho on 9/12/24.
//

import SwiftUI
import SwiftData
import ComposableArchitecture
import Kingfisher
struct MyStickerView: View {
    @Bindable var store: StoreOf<MyStickerFeature>
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                Group {
                    Text("\(store.myStickers.count)").foregroundStyle(.main)+Text("/\(store.allStickersCount)개").foregroundStyle(.gray6)
                }   .customTextStyle(.title)
                    .padding(.bottom,12)
                Text("여행을 통해 명소 스티커를 모아보세요.")
                    .foregroundStyle(.gray5)
                    .customTextStyle(.body1)
                    .padding(.bottom, 16)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Region.allCases, id: \.rawValue) { region in
                            Button {
                                store.send(.tapCategorize(region))
                            } label: {
                                Text(region.rawValue)
                                    .customTextStyle(.smallBtn)
                                    .frame(width: 82, height: 29)
                                    .foregroundStyle(store.selectedRegion == region ? .black : .white)
                                    .background(store.selectedRegion == region ? .gray6 : .clear)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(
                                                Color.gray6, // 선택 여부에 따라 테두리 색상 변경
                                                lineWidth: 1
                                            )
                                    )
                            }
                        }
                    }
                }.padding(.bottom, 32)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray1)
                        .frame(maxWidth: .infinity)
              
                    VStack {
                    if let subRegionStickers = store.categorizedStickers[store.selectedRegion.rawValue] {
                        
                        ForEach(subRegionStickers, id: \.self) { subregion in
                            if let firstSticker = subregion.first {
                                // 하위 지역 이름
                                Text(firstSticker.region)
                                    .customTextStyle(.subheadline)
                                    .foregroundStyle(.white)
                                    .padding(.top, 16)
                            }
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                                ForEach(subregion, id: \.stickerCode) { sticker in
                                    VStack {
                                        let isCollected = store.myStickers.contains { $0.stickerCode == sticker.stickerCode }
                                        KFImage.url(URL(string: sticker.url)!)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 82)
                                            .opacity(isCollected ? 1 : 0.5)
                                        Text(sticker.name)
                                            .font(.caption)
                                            .foregroundColor(isCollected ? .primary : .gray)
                                    }
                                }
                                
                            }
                        }
                    } else {
                        Text("스티커가 없습니다.")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                }.frame(maxHeight: .infinity)
                
                
                
            }
        }
        .onAppear {
            store.send(.fetchAllStickers)
        }
        .padding(.horizontal, 32)
        .applyBackground(color: .background)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("나의 스티커")
                    .foregroundStyle(.white)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    store.send(.backbuttonTapped)
                }, label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(.white)
                })
            }
        }
        
    }
    
    
}
#Preview { @MainActor in
    MyStickerView(store: .init(initialState: MyStickerFeature.State(categorizedStickers: [
        "서울/경기": [
            // 하위 지역: 서울
            [
                StickerData(
                    stickerType: "STICKER",
                    name: "경복궁",
                    url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/SL01.png",
                    isCollected: true,
                    stickerCode: "SL01"
                ),
                StickerData(
                    stickerType: "STICKER",
                    name: "창덕궁 후원",
                    url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/SL08.png",
                    isCollected: true,
                    stickerCode: "SL08"
                )
            ],
            // 하위 지역: 수원
            [
                StickerData(
                    stickerType: "STICKER",
                    name: "광안리 대교",
                    url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/BS05.png",
                    isCollected: true,
                    stickerCode: "SW01"
                ),
                StickerData(
                    stickerType: "STICKER",
                    name: "BIFF 광장",
                    url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/BS01.png",
                    isCollected: true,
                    stickerCode: "SW02"
                )
            ]
        ],
        "제주": [
            [
                StickerData(
                    stickerType: "STICKER",
                    name: "월드컵경기장",
                    url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/SW04.png",
                    isCollected: true,
                    stickerCode: "JJ01"
                )
            ]
        ],
        "강원": [
            [
                StickerData(
                    stickerType: "STICKER",
                    name: "BIFF 광장",
                    url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/BS01.png",
                    isCollected: true,
                    stickerCode: "GN01"
                ),
                StickerData(
                    stickerType: "STICKER",
                    name: "광안리 대교",
                    url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/BS05.png",
                    isCollected: true,
                    stickerCode: "GN02"
                )
            ]
        ]
    ]), reducer: {
        MyStickerFeature()
    }))
}
