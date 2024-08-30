//
//  StickersFeature.swift
//  Boleto
//
//  Created by Sunho on 8/30/24.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

@Reducer
struct StickersFeature {
    @ObservableState
    struct State: Equatable {
        var stickers: IdentifiedArrayOf<Sticker> = []
    }
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case addSticker(String)
        case moveSticker(id: Sticker.ID, to: CGPoint)
        case removeSticker(id: Sticker.ID)
        case selectSticker(id: Sticker.ID)
        case addBubble
        case unselectSticker
    }
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addBubble:
                let bubble = Sticker(id: UUID(), image: "bubble", position: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2),isSelected: true, type: .bubble)
                state.stickers.append(bubble)
                return .send(.selectSticker(id: bubble.id))
            case let .addSticker(sticker):
                let stickerValue = Sticker(id: UUID(), image: sticker, position:   CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2), isSelected: true, type: .regular)
                state.stickers.append(stickerValue)
                return .send(.selectSticker(id: stickerValue.id))
                
            case let .moveSticker(id, to):
                state.stickers[id: id]?.position = to
                return .send(.selectSticker(id: id))
                
            case let .removeSticker(id):
                state.stickers.remove(id: id)
                return .none
                
            case let .selectSticker(id):
                for index in state.stickers.indices {
                    state.stickers[index].isSelected = (state.stickers[index].id == id)
                }
                return .none
            case .unselectSticker:
                for index in state.stickers.indices {
                    state.stickers[index].isSelected = false
                }
                return .none
          
            case .binding:
                return .none
            }
        }
    }
}
