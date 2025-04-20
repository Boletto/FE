//
//  StickerView.swift
//  Boleto
//
//  Created by Sunho on 8/15/24.
//

import SwiftUI
import ComposableArchitecture
struct StickerPickerView: View {
    @Bindable var store: StoreOf<StickerPickerFeature>
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Text("스티커 추가")
                    .customTextStyle(.pageTitle)
                    .foregroundStyle(.white)
                    .padding()
                SearchBar(text: $store.findStickerText,placeholder: "찾으시려는 스티커를 입력해주세요")
                stickerSectionView
                    .padding(.horizontal,32)
                    .padding(.top,16)
                Spacer()
            }
        }.applyBackground(color: .modal)
            .task {
                store.send(.fetchMyStickers)
            }
    }
    private var stickerSectionView: some View  {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing : 16){
                defaultStickerSectionView
                    .padding(.bottom, 40)
                myStickerSelectionView
            }
        }
    }
    private var defaultStickerSectionView: some View {
        VStack(alignment: .leading, spacing : 0){
            Text("기본 스티커")
                .customTextStyle(.subheadline)
                .foregroundStyle(.white)
                .padding(.bottom,16)
            HStack(spacing: 24) {
                ForEach(store.defaultStickers.prefix(2),id: \.id) { sticker in
                    AsyncImageView(urlString: sticker.url, imagetype: .sticker)
                    .onTapGesture {
                        store.send(.addSticker(sticker))
                    }
                }
            }.padding(.horizontal, 31).padding(.bottom, 28)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing: 19), count: 4), spacing: 32) {
                ForEach(store.defaultStickers.dropFirst(2), id: \.id) { sticker in
                    AsyncImageView(urlString: sticker.url, imagetype: .sticker)
                    .frame(maxHeight: 72)
                    .onTapGesture {
                        store.send(.addSticker(sticker))
                    }
                }
            }
        }
        
    }
    private var myStickerSelectionView: some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            Text("나의 스티커")
                .customTextStyle(.subheadline)
                .foregroundStyle(.white)
            ForEach(store.filteredMystickers.keys.sorted(),id:\.self) { region in
                Text(region)
                    .customTextStyle(.smallBtn)
                    .foregroundStyle(.gray6)
                    .padding(.top, 24)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(),spacing: 32), count: 4), spacing: 16) {
                    ForEach(store.filteredMystickers[region]!, id: \.id) { sticker in
                        VStack(spacing: 10) {
                            AsyncImageView(urlString: sticker.url, imagetype: .sticker)
                            .frame(height: 52)
                            if region != "기타"{
                                Text(sticker.name)
                                    .customTextStyle(.small)
                                    .foregroundStyle(.white)
                            }
                        }
                        .onTapGesture {
                            store.send(.addSticker(sticker))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    StickerPickerView(store: .init(initialState: StickerPickerFeature.State(findStickerText: "경",
        myStickers: [
            "서울" : [
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
            "수원": [
                StickerData(stickerType: "STICKER", name: "월드컵경기장", url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/SW04.png", isCollected: true, stickerCode: "SW04")
            ],
            "부산": [
                StickerData(
                    stickerType: "STICKER",
                    name: "BIFF 광장",
                    url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/BS01.png",
                    isCollected: true,
                    stickerCode: "BS01"
                ),
                StickerData(
                    stickerType: "STICKER",
                    name: "광안리 대교",
                    url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/BS05.png",
                    isCollected: true,
                    stickerCode: "BS05"
                )
            ]
        ],
        defaultStickers: [
            StickerData(
                stickerType: "STICKER",
                name: "기본 스티커1",
                url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/ST01.png",
                isCollected: true,
                stickerCode: "ST01"
            ),
            StickerData(
                stickerType: "STICKER",
                name: "기본 스티커2",
                url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/ST02.png",
                isCollected: true,
                stickerCode: "ST02"
            ),
            StickerData(
                stickerType: "STICKER",
                name: "기본 스티커3",
                url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/ST03.png",
                isCollected: true,
                stickerCode: "ST03"
            ),
            StickerData(
                stickerType: "STICKER",
                name: "기본 스티커4",
                url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/ST04.png",
                isCollected: true,
                stickerCode: "ST04"
            ),
            StickerData(
                stickerType: "STICKER",
                name: "기본 스티커1",
                url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/ST05.png",
                isCollected: true,
                stickerCode: "ST05"
            ),
            StickerData(
                stickerType: "STICKER",
                name: "기본 스티커2",
                url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/ST06.png",
                isCollected: true,
                stickerCode: "ST06"
            ),
            StickerData(
                stickerType: "STICKER",
                name: "기본 스티커3",
                url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/ST07.png",
                isCollected: true,
                stickerCode: "ST07"
            ),
            StickerData(
                stickerType: "STICKER",
                name: "기본 스티커4",
                url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/ST08.png",
                isCollected: true,
                stickerCode: "ST08"
            )
        ]
    ), reducer: {
        StickerPickerFeature()
    }))
}
