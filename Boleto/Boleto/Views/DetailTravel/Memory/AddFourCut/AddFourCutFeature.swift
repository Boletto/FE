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
        var savedImages = [FrameItem]()
        var defaultImages:[FrameItem] = [FrameItem(imageUrl: "whiteFrame", idx: 3), FrameItem(imageUrl: "blackFrame",idx:2), FrameItem(imageUrl: "checkerFrame", idx: 1) ]
        var selectedPhotos: [PhotosPickerItem?] = [nil,nil,nil,nil]
        var fourCutImages: [UIImage?] = [nil,nil,nil,nil]
        var isAbleToImage: Bool = false
        var selectedFrame = FrameItem(imageUrl: "whiteFrame", idx: 3)
        var isDefaultFrameSelected: Bool = true  // 추가된 플래그
    }
    
    enum Action {
        case selectImage(FrameItem, isDefault: Bool)
        
        case updateSavedImages([FrameItem])
        case selectPhoto(Int)
        case loadPhoto(Int, UIImage?)
        case finishTapped
        case checkIsAbleToImage
        case fetchFrame
        case successUpload(FourCutModel)
        //        case fourCutAdded(FourCut)
        
    }
    @Dependency(\.travelClient) var travelClient
    @Dependency(\.userClient) var userClient
    var body: some ReducerOf<Self> {
        Reduce { state ,action in
            switch action {
      
            case .updateSavedImages(let items):
                state.savedImages = items
                return .none
            case .fetchFrame:
                return .run { send in
                    let frames = try await userClient.getUserFrames()
                    let customFrames = frames.filter { ![0, 1, 2].contains($0.idx) }
                    await send(.updateSavedImages(customFrames))
                }
            case .selectImage(let item, let isDefault):
                state.selectedFrame = item
                state.isDefaultFrameSelected = isDefault
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
                let frameId = state.selectedFrame.idx
                let imageDataArray = images.compactMap { image -> Data? in
//                    let resizedImage = image?.resiz
                    return image?.jpegData(compressionQuality: 0.2)
                }
                return .run {send in
                    let res  =  try await travelClient.postFourPhoto(travelID, pictureIndex, frameId, imageDataArray)
                    await send(.successUpload(res))
                    
                }
            case .successUpload:
                return .none
            }
        }
    }
    
    
}

