//
//  MyStickerFeature.swift
//  Boleto
//
//  Created by Sunho on 9/12/24.
//
import ComposableArchitecture
@Reducer
struct MyStickerFeature {
    @ObservableState
    struct State: Equatable {
        var mySticker: [Badge] = [Badge(title: "남산", imageString: "seoulSticker1"), Badge(title: "경복궁", imageString: "seoulSticker2")]
    }
    enum Action  {
        
    }
    var body: some ReducerOf<Self> {
        Reduce {state, action in
            switch action {
                
            }
        }
    }
}
