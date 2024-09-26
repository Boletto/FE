//
//  AddFourCutFeature.swift
//  Boleto
//
//  Created by Sunho on 8/17/24.
//

import Foundation
import PhotosUI
import ComposableArchitecture
import SwiftUI

@Reducer
struct AddFourCutFeature {
    @Dependency(\.dismiss) private var dismiss
    @ObservableState
    struct State: Equatable {
        var travelID: Int
        var pictureIndex: Int
        var savedImages = ["dong", "gas", "beef", "beef1","beef2","beef3","beef4"]
        var defaultImages = ["whiteFrame","blackFrame","checkerframe", "defaultFrame"]
        @Shared(.appStorage("userID")) var userId: Int = 0
        var selectedImage: String?
        var selectedPhotos: [PhotosPickerItem?] = [nil,nil,nil,nil]
        var fourCutImages: [UIImage?] = [nil,nil,nil,nil]
        var isAbleToImage: Bool = false
    }
  
    enum Action {
        case selectImage(Int, Bool)
        case selectPhoto(Int)
        case loadPhoto(Int, UIImage?)
        case finishTapped(UIImage?)
        case checkIsAbleToImage
        case fourCutAdded(UIImage)
        
    }
    @Dependency(\.travelClient) var travelClient
    var body: some ReducerOf<Self> {
        Reduce { state ,action in
            switch action {
            case .selectImage(let index, let isDefault):
                state.selectedImage = isDefault ? state.defaultImages[index] : state.savedImages[index]
                return .none
            case .selectPhoto(let index):
                return .none
            case .loadPhoto(let index, let image):
                state.fourCutImages[index] = image
                return .send(.checkIsAbleToImage)
            case .checkIsAbleToImage:
                state.isAbleToImage = !state.fourCutImages.contains(where: {$0 == nil})
                return .none
            case .finishTapped(let image):
                let userId = state.userId
                let travelID = state.travelID
                let picutureIndex = state.pictureIndex
                
                guard let imageData = image?.pngData() else {return .none}
                return .run {send in
                   let result =  try await travelClient.postSinglePhoto(userId, travelID, picutureIndex, imageData)
                    if result {
                        if let image = image {
                            await send(.fourCutAdded( image))
                        }
                        await dismiss()
                    }
//                    try await travelClient.
                }
            case .fourCutAdded:
                return .none
            }
        }
    }

   
}

