//
//  StickerManagementFeature.swift
//  Boleto
//
//  Created by Sunho on 8/30/24.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

@Reducer
struct StickerManagementFeature {
    @ObservableState
    struct State: Equatable {
        var stickers: IdentifiedArrayOf<StickerItem> = []
        var speechs: IdentifiedArrayOf<SpeechItem> = []
        @Shared(.appStorage("speechImageURL")) var speechImageURL: String = ""
    }
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case setStickers([StickerItem], [SpeechItem])
        case addSpeech
        case addSticker(StickerData)
        case selectSticker(id: UUID)
        case moveSticker(id: UUID, to: CGPoint)
        case removeSticker(id: UUID)
        case unselectSticker
    }
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case let .setStickers(stickers, speechs):
                state.stickers = IdentifiedArrayOf(uniqueElements: stickers)
                 state.speechs = IdentifiedArrayOf(uniqueElements: speechs)
                 return .none
            case .addSpeech:
                let speech = SpeechItem(id:  UUID(), name: "", stickerCode: "SP01", imageString: state.speechImageURL, position: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2), isSelected: true,text: "")
                state.speechs.append(speech)
                return .send(.selectSticker(id: speech.id))
            case .addSticker(let sticker):
                let stickerItem = StickerItem(id: UUID(), name: sticker.name, stickerCode: sticker.stickerCode, imageString:  sticker.url , position: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2))
                state.stickers.append(stickerItem)
                return .send(.selectSticker(id: stickerItem.id))
            case .selectSticker(let id):
                for index in state.stickers.indices {
                    state.stickers[index].isSelected = (state.stickers[index].id == id)
                }
                for index in state.speechs.indices {
                    state.speechs[index].isSelected = (state.speechs[index].id == id)
                }
                return .none
            case let .moveSticker(id, to):
                if let index = state.stickers.firstIndex(where: { $0.id == id }) {
                    state.stickers[index].position = to
                }
                if let index = state.speechs.firstIndex(where: { $0.id == id }) {
                    state.speechs[index].position = to
                }
                return .send(.selectSticker(id: id))
            case let .removeSticker(id):
                if let _ = state.stickers.firstIndex(where: { $0.id == id }) {
                    state.stickers.remove(id: id)
                }

                // speechs 배열에서 해당 ID를 찾고 제거
                if let _ = state.speechs.firstIndex(where: { $0.id == id }) {
                    state.speechs.remove(id: id)
                }
                return .none
                case .unselectSticker:
                for index in state.stickers.indices {
                    state.stickers[index].isSelected = false
                }

                // 모든 스피치의 isSelected를 false로 설정
                for index in state.speechs.indices {
                    state.speechs[index].isSelected = false
                }
                    return .none

            }
        }
    }
}
