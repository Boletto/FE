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
import SwiftData

@Reducer
struct AddFourCutFeature {

    @ObservableState
    struct State: Equatable {
        var travelID: Int
        var pictureIndex: Int
        var selectedPhotos: [PhotosPickerItem?] = [nil,nil,nil,nil]
        var fourCutImages: [UIImage?] = [nil,nil,nil,nil]
        var isAbleToImage: Bool = false
        var defaultFrames: [FrameItem] = []
        var myFrames: [FrameItem] = []
        var selectedFrame: FrameItem?

    }
    
    enum Action: Equatable {
        case selectImage(FrameItem)
        case updateFrames([FrameData])
        case selectPhoto(Int)
        case loadPhoto(Int, UIImage?)
        case finishTapped
        case checkIsAbleToImage
        case fetchFrame
        case successUpload
        case failAlreadyLocked
    }

    @Dependency(\.memoryClient) var memoryclient
    @Dependency(\.userClient) var userClient
    @Dependency(\.databaseClient.context) var context
    var body: some ReducerOf<Self> {
        Reduce { state ,action in
            switch action {
            case .updateFrames(let items):
                let defaultFrames =  items.filter {$0.frameType == "SYSTEM"}.map{FrameItem(imageUrl: $0.frameURL, frameCode: $0.frameCode, frameType: "SYSTEM")}
                state.defaultFrames = defaultFrames
                state.myFrames = items.filter {$0.frameType == "CUSTOM"}.map{FrameItem(imageUrl: $0.frameURL, frameCode: $0.frameCode, frameType: "CUSTOM")}
                state.selectedFrame = defaultFrames[0]
                return .none
            case .fetchFrame:
                return .run { send in
                    do {
                        let frameContext = try context()
                        let myFrames = try frameContext.fetch(FetchDescriptor<FrameData>())
                        await send(.updateFrames(myFrames))
                    }
                }
            case .selectImage(let item):
                state.selectedFrame = item
                return .none
            case .selectPhoto:
                return .none
            case .loadPhoto(let index, let image):
                state.fourCutImages[index] = image
                return .send(.checkIsAbleToImage)
            case .checkIsAbleToImage:
                state.isAbleToImage = !state.fourCutImages.contains(where: {$0 == nil})
                return .none
            case .finishTapped:
                guard let selectedFrame = state.selectedFrame else {return .none}
                let travelID = state.travelID
                let pictureIndex = state.pictureIndex
                let images = state.fourCutImages
                let frameCode = selectedFrame.frameCode
                let imageDataArray = images.compactMap { image -> Data? in
                    return image?.jpegData(compressionQuality: 0.4)
                }
                return .run {send in
                    do {
                        _  =  try await memoryclient.postCreateTravelMemory(travelID,pictureIndex, "FOUR_CUT", frameCode, imageDataArray)
                        await send(.successUpload)
                    } catch let error as CustomError {
                        switch error {
                        case .alreadyLocked:
                            await send(.failAlreadyLocked)
                        default:
                            print(error)
                        }
                        
                    }}
            case .successUpload:
                return .none
            case .failAlreadyLocked:
                return .none
            }
        }
    }
    
    
}

