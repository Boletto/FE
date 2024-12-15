////
////  StickerFeature.swift
////  Boleto
////
////  Created by Sunho on 8/25/24.
////
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
        var myStickers: [String: [StickerData]] = [:]
        var defaultStickers: [StickerData] = []
        var filteredMystickers: [String: [StickerData]] = [:]
    }
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case addSticker(StickerData)
        case fetchMyStickers
        case showMyStickers([StickerData])
    }
    @Dependency(\.databaseClient.context) var context
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {state, action in
            switch action {
            case .binding:
                let searchText = state.findStickerText
                if searchText.isEmpty {
                    state.filteredMystickers = state.myStickers
                }else {
                    state.filteredMystickers = state.myStickers.mapValues({
                        $0.filter {$0.name.contains(searchText) || $0.region.contains(searchText)}
                    }).filter { !$0.value.isEmpty } 
                }
                return .none
            case let .addSticker(sticker):
                return .run {send in await self.dismiss()}
            case .fetchMyStickers:
                return .run { send in
                    do {
                        let stickerContext = try context()
                        let myStickers = try stickerContext.fetch(FetchDescriptor<StickerData>(predicate: #Predicate<StickerData> { dbsticker in
                            dbsticker.isCollected
                        }))
                        await send(.showMyStickers(myStickers))
                    }
                }
            case .showMyStickers(let stickers):
                let collectStickers = stickers.filter{$0.name != "기본스티커"}
                state.myStickers = Dictionary(grouping: collectStickers){$0.region}
                state.defaultStickers = stickers.filter{$0.name == "기본스티커"} .sorted { $0.stickerCode < $1.stickerCode }
                state.filteredMystickers = state.myStickers
                return .none

            }
        }
    }
}
