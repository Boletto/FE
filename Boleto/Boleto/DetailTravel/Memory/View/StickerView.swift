//
//  StickerView.swift
//  Boleto
//
//  Created by Sunho on 8/15/24.
//

import SwiftUI
import ComposableArchitecture

struct StickerView: View {
    @State private var draggedSticker: String = ""
    @Bindable var store: StoreOf<StickerPickerFeature>
    var body: some View {
        ZStack {
            Color.modalColor.ignoresSafeArea(.all,edges: .bottom)
            VStack {
                Text("스티커 추가")
                    .font(.headline)
                    .padding()
                SearchBar(text: $store.findStickerText)
                defaultStickerView
                    .padding(.leading,32)
                    .padding(.top,30)
                Spacer()
            }
        }
    }
    var defaultStickerView: some View {
        VStack(alignment: .leading, spacing : 0){
            Text("기본 스티커")
                .font(.system(size: 15, weight: .semibold))
                .padding(.bottom,16)
            HStack(spacing: 30) {
                ForEach(store.defaultStickers.prefix(2),id: \.self) {sticker in
                    Image(sticker)
                        .onTapGesture {
                            store.send(.addSticker(sticker: sticker))
                        }
                }
                Spacer()

            }
            Spacer().frame(height: 18)
            HStack(spacing: 30) {
                ForEach(store.defaultStickers.dropFirst(2),id: \.self) {sticker in
                    Image(sticker)
                        .onTapGesture {
                            store.send(.addSticker(sticker: sticker))
                        }
                }
            }
            Spacer()
        }
    }
}

//#Preview {
//    StickerView(store: Store(initialState: StickerFeature.State()){
//        StickerFeature()
//    })
//}
