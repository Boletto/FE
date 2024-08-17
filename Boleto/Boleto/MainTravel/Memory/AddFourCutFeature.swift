//
//  AddFourCutFeature.swift
//  Boleto
//
//  Created by Sunho on 8/17/24.
//

import Foundation
import PhotosUI
import ComposableArchitecture

@Reducer
struct AddFourCutFeature {
    @ObservableState
    struct State {
        var savedImages = ["dong", "gas", "beef", "beef1","beef2","beef3","beef4"]
        var defaultImages = ["beef3","beef4","beef", "beef1","beef2", "dong", "gas"]
        var selectedImage: String?
    }
    enum Action {
        case selectImage(Int, Bool)
    }
    var body: some ReducerOf<Self> {
        Reduce { state ,action in
            switch action {
            case .selectImage(let index, let isDefault):
                state.selectedImage = isDefault ? state.defaultImages[index] : state.savedImages[index]
                return .none
            }
        }
    }
   
}
