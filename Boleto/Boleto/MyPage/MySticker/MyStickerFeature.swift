//
//  MyStickerFeature.swift
//  Boleto
//
//  Created by Sunho on 9/12/24.
//
import ComposableArchitecture
import SwiftData

@Reducer
struct MyStickerFeature {
    @Dependency(\.dismiss) var dismiss
//    @Dependency(\.swiftDataContext) var context
    @ObservableState
    struct State: Equatable {
        var mySticker: [Badge] = [Badge(title: "남산", imageString: "seoulSticker1"), Badge(title: "경복궁", imageString: "seoulSticker2")]
       
    }
    enum Action  {
        case backbuttonTapped
        
    }
    var body: some ReducerOf<Self> {
        Reduce {state, action in
            switch action {
            case .backbuttonTapped:
                return .run { _ in await self.dismiss() }
            }
        }
    }
}
