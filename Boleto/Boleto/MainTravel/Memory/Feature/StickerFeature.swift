//
//  StickerFeature.swift
//  Boleto
//
//  Created by Sunho on 8/25/24.
//

import Foundation
import ComposableArchitecture
import UIKit

@Reducer
struct StickerFeature {
    @Dependency(\.dismiss) private var dismiss
    @ObservableState
    struct State: Equatable {
        var findStickerText: String = "" 
        var selectedStickers = [Sticker]()
        var defaultStickers = [ "sticker2","sticker1","sticker3","sticker4","sticker5",]
    }
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case addSticker(sticker: String)
        case moveSticker(id: UUID, to : CGPoint)
        case removeSticker(id: UUID)
    }
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {state, action in
            switch action {
            case .binding:
                return .none
            case let .addSticker(sticker):
//                state.selectedStickers.append(Sticker(id: UUID(), image: sticker, position: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)))
                return .run {send in await self.dismiss()}
            case let .moveSticker(id, to) :
                if let index = state.selectedStickers.firstIndex(where: {$0.id == id}) {
                    state.selectedStickers[index].position = to
                }
                return .none
            case let .removeSticker(id):
                state.selectedStickers.removeAll {$0.id == id}
                return .none
            }
        }
    }
}
