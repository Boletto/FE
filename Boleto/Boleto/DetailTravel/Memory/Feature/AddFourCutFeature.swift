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
        var selectedImage: String?
        var selectedPhotos: [PhotosPickerItem?] = [nil,nil,nil,nil]
        var fourCutImages: [UIImage?] = [nil,nil,nil,nil]
        var isAbleToImage: Bool = false
    }
  
    enum Action {
        case selectImage(Int, Bool)
        case selectPhoto(Int)
        case loadPhoto(Int, UIImage?)
        case finishTapped
        case checkIsAbleToImage
        case fetchFrame
//        case fourCutAdded(FourCut)
        
    }
    @Dependency(\.travelClient) var travelClient
    @Dependency(\.userClient) var userClient
    var body: some ReducerOf<Self> {
        Reduce { state ,action in
            switch action {
            case .fetchFrame:
                return .run { _ in
                    let result = try await userClient.getUserFrames()
                    print(result)
                }
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
            case .finishTapped:
                let travelID = state.travelID
                let pictureIndex = state.pictureIndex
                let images = state.fourCutImages
                
                let imageDataArray = images.compactMap { image -> Data? in
                    return image?.jpegData(compressionQuality: 0.1)
                   }
                let totalSizeInMB = Double(imageDataArray.reduce(0) { $0 + $1.count }) / (1024.0 * 1024.0)
                print(totalSizeInMB)
                return .run {send in
                    let res  =  try await travelClient.postFourPhoto(travelID, pictureIndex, 0, imageDataArray)
                    print(res)
//                    let photoItem = PhotoItem(id: photoId, image: Image(uiImage: image!), pictureIdx: pictureIndex, imageURL: photoUrl)
//                    let fourcutItem = FourCut(pictureurls: res.pictureUrl, frametype: res.frameType, id: res.fourCutID, index: res.pictureIdx)
////
               
//                            await send(.fourCutAdded( fourcutItem))
                        
                        await dismiss()

                }
//            case .fourCutAdded:
//                return .none
            }
        }
    }

   
}

