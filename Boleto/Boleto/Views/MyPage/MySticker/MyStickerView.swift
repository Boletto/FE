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
    @Bindable var store: StoreOf<MyStickerFeature>
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                Text("\(store.myStickers.count)").foregroundStyle(.main)+Text("/\(store.allStickersCount)개").foregroundStyle(.gray6)
            }   .customTextStyle(.title)
                .padding(.top, 40)
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
                ScrollView(showsIndicators: false) {
                    LazyVStack {
                        if let subRegionStickers = store.categorizedStickers[store.selectedRegion.rawValue] {
                            ForEach(subRegionStickers, id: \.self) { subregion in
                                if let firstSticker = subregion.first {
                                    // 하위 지역 이름
                                    HStack {
                                        Text(firstSticker.region)
                                            .customTextStyle(.subheadline)
                                            .foregroundStyle(.white)
                                            .padding(.top, 16)
                                        Spacer()
                                    }
                                }
                                
                                LazyVGrid(columns: [GridItem(.flexible(),spacing: 22), GridItem(.flexible(),spacing: 22), GridItem(.flexible())]) {
                                    ForEach(subregion, id: \.stickerCode) { sticker in
                                        VStack {
                                            let isCollected = store.myStickers.contains { $0.stickerCode == sticker.stickerCode }
                                            Spacer()
                                            AsyncImageView(urlString: sticker.url, targetSize: CGSize(width: 240, height: 240), imagetype: .sticker)
                                            .opacity(isCollected ? 1 : 0.5)
                    
                                         
                                            Spacer()
                                            Text(sticker.name)
                                                .customTextStyle(.small)
                                                .foregroundColor(isCollected ? .white : .gray)
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
                }.padding(.bottom,16)
                    .padding(.horizontal, 24)
                
                    
            }.frame(maxHeight: .infinity)
        }   .padding(.horizontal, 32)
            .onAppear {
                store.send(.fetchAllStickers)
            }
    }
}
//extension MyStickerView {
//    func checkMemoryUsage() {
//        let cache = ImageCache.default
//                // 캐시된 이미지 키 나열
//        let keys = cache.memoryStorage.
//                var totalCost: Int = 0
//                for key in keys {
//                    if let image = cache.memoryStorage.value(forKey: key) {
//                        // 이미지의 메모리 크기 추정 (예: 픽셀 수 * 4바이트)
//                        let cost = Int(image.size.width * image.size.height * 4)
//                        totalCost += cost
//                    }
//                }
//                print("추정 메모리 캐시 사용량: \(totalCost) bytes")
//                let mb = Double(totalCost) / 1024.0 / 1024.0
//                print("추정 메모리 캐시 사용량: \(mb) MB")
//           }
//}
