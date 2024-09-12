//
//  MyStickerView.swift
//  Boleto
//
//  Created by Sunho on 9/12/24.
//

import SwiftUI
import ComposableArchitecture
struct MyStickerView: View {
    @Bindable var store: StoreOf<MyStickerFeature>
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Group {
                        Text("\(store.mySticker.count)" ).foregroundStyle(.main) + Text("/15개").foregroundStyle(.white)
                    }
                        .customTextStyle(.title)
                    
                    Text("여행을 통해 명소 스티커를 모아보세요.")
                        .customTextStyle(.body1)
                        .foregroundStyle(.gray5)
                }
                Spacer()
            }
            
        }.applyBackground(color: .background)
    }
//    var stickerGridView: some View {
////        ScrollView {
////            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()),GridItem(.flexible())], content: {
////                /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
////                /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
////            })
////        }
//    }
}

#Preview {
    NavigationStack {
        MyStickerView(store: .init(initialState: MyStickerFeature.State(), reducer: {
            MyStickerFeature()
        }))
    }
}
