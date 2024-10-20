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
            VStack {
                Text("스티커 추가")
                    .customTextStyle(.pageTitle)
                    .foregroundStyle(.white)
                    .padding()
                SearchBar(text: $store.findStickerText)
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
        ScrollView {
            VStack(alignment: .leading, spacing : 16){
                defaultStickerSectionView
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
                //기본 스티커 5개인데 2개,3개배치하기 위해
                HStack(spacing: 30) {
                    ForEach(store.defaultStickers.prefix(2),id: \.self) {sticker in
                        Image(sticker.rawValue)
                            .onTapGesture {
                                store.send(.addSticker(sticker: sticker))
                            }
                    }
                    Spacer()
                }
                Spacer().frame(height: 18)
                HStack(spacing: 30) {
                    ForEach(store.defaultStickers.dropFirst(2),id: \.self) {sticker in
                        Image(sticker.rawValue)
                            .onTapGesture {
                                store.send(.addSticker(sticker: sticker))
                            }
                    }
                }
            }
        
    }
    private var myStickerSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("나의 스티커")
                .customTextStyle(.subheadline)
                .foregroundStyle(.white)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                ForEach(store.myStickers, id: \.hashValue) { item in
                    VStack {
                        Image(item.rawValue)
                            .resizable()
                            .scaledToFit()
                        Text(item.koreanString)
                            .customTextStyle(.small)
                            .foregroundStyle(.white)
                    }
                    .onTapGesture {
                        store.send(.addSticker(sticker: item))
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

//#Preview {
//    StickerView(store: Store(initialState: StickerFeature.State()){
//        StickerFeature()
//    })
//}
