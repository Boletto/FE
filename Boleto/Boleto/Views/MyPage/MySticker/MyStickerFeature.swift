//
//  MyStickerFeature.swift
//  Boleto
//
//  Created by Sunho on 9/12/24.
//
import ComposableArchitecture
import SwiftData
import SwiftUI
enum Region: String, CaseIterable {
    case seoulGyeongi = "서울/경기"
    case gangwon = "강원"
    case gyeongsang = "경상"
    case jeolla = "전라"
    case jeju = "제주"
    var stickerPrefixes: [String] {
        switch self {
        case .seoulGyeongi: return ["SL", "SW"]
        case .gangwon: return ["GN"]
        case .gyeongsang: return ["GJ", "BS"]
        case .jeolla: return ["YS"]
        case .jeju: return ["JJ"]
        }
    }
}
@Reducer
struct MyStickerFeature {
    @ObservableState
    struct State: Equatable {
        var myStickers: [StickerData] = []
        var categorizedStickers: [String: [[StickerData]]] = [:] // 예: ["서울": [StickerData]]
        var selectedRegion: Region = .seoulGyeongi
        var allStickersCount = 0
    }
    enum Action: Equatable  {
        case backbuttonTapped
        case fetchAllStickers
        case updateCategorizedStickers([String: [[StickerData]]])
        case updateMyStickers([StickerData], Int)
        case tapCategorize(Region)
    }
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.databaseClient.context) var context
    var body: some ReducerOf<Self> {
        Reduce {state, action in
            switch action {
            case .backbuttonTapped:
                return .run { _ in await self.dismiss() }
            case .fetchAllStickers:
                return .run { send in
                    do {
                        let stickerContext = try context()
                        let allStickers = try stickerContext.fetch(FetchDescriptor<StickerData>(predicate: #Predicate<StickerData> {
                            $0.name != "기본스티커"
                        }))
                                                                   
                        let myStickers = try stickerContext.fetch(FetchDescriptor<StickerData>(predicate: #Predicate<StickerData> { dbsticker in
                            dbsticker.isCollected && dbsticker.name != "기본스티커"
                        }))
                        var categorized: [String: [[StickerData]]] = [:]
                        for region in Region.allCases {
                            let stickersForRegion = allStickers.filter { sticker in
                                region.stickerPrefixes.contains { prefix in
                                    sticker.stickerCode.hasPrefix(prefix)
                                }
                            }
                            
                            // 하위 지역별로 그룹화
                            let groupedBySubRegion = Dictionary(grouping: stickersForRegion, by: { $0.region })
                            categorized[region.rawValue] = groupedBySubRegion.values.map { $0 }
                        }
                        await send(.updateCategorizedStickers(categorized))
                        await send(.updateMyStickers(myStickers, allStickers.count))
                    }
                }
            case .updateCategorizedStickers(let catorized):
                state.categorizedStickers = catorized
                return .none
            case .updateMyStickers(let stickers, let cnt):
                state.myStickers = stickers
                state.allStickersCount = cnt
                return .none
            case .tapCategorize(let region):
                state.selectedRegion = region
                return .none
                
                
            }
        }
    }
}
