//
//  StickerFeature.swift
//  Boleto
//
//  Created by Sunho on 8/25/24.
//

import SwiftData
import ComposableArchitecture
import UIKit

@Reducer
struct StickerPickerFeature {
    @Dependency(\.dismiss) private var dismiss
    @ObservableState
    struct State: Equatable {
        var findStickerText: String = "" 
        var selectedStickers = [Sticker]()
        var defaultStickers: [StickerImage] = [.hello,.imhere,.fly,.letsgo,.welcome]
        var myStickers: [StickerImage] = []
    }
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case addSticker(sticker: StickerImage)
        case fetchMyStickers
        case showMyStickers([StickerImage])
    }
    @Dependency(\.stickerClient) var stickerClient
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {state, action in
            switch action {
            case .binding:
                return .none
            case let .addSticker(sticker):
                return .run {send in await self.dismiss()}
            case .fetchMyStickers:
                return .run { send in
                    let mine = try stickerClient.fetchMyBadges()
                    await send(.showMyStickers(mine))
                }
            case .showMyStickers(let stickers):
                state.myStickers = stickers
                return .none

            }
        }
    }
}
