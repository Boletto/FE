//
//  FrameNotificationFeature.swift
//  Boleto
//
//  Created by Sunho on 9/18/24.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI
@Reducer
struct FrameNotificationFeature {
    @Dependency(\.dismiss) var dismiss
    @ObservableState
    struct State: Equatable {
        var selectedItem: PhotosPickerItem?
        var selectedFrame: UIImage?
        let badgeType: SpotType
    }
    enum Action: Equatable {
        case tapsaveFrame
        case backButtonTapped
        case imagePickerSelection(PhotosPickerItem?)
        case setFrameImage(UIImage?)
    }
    @Dependency(\.userClient) var userClient
    @Dependency(\.frameDBClient) var frameClient
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .tapsaveFrame:
                let selectedFrame = state.selectedFrame
                return .run {send in
                    guard let selectFrame = selectedFrame else {return }
                    let data = selectFrame.jpegData(compressionQuality: 0.4)!
                    let frameData = try await userClient.postCustomFrame(data)
                     frameClient.saveCollectFrame(FrameData(frameURL: frameData.imageUrl, frameCode: frameData.frameCode, frameType: frameData.frameType))
                    await dismiss()
                }
            case .backButtonTapped:
                return .run { _ in await self.dismiss() }
            case .imagePickerSelection(let image):
                state.selectedItem = image
                return .run { send in
                    let data = try await image?.loadTransferable(type: Data.self)
                    guard let data = data , let uiImage = UIImage(data: data) else {return}
                    await send(.setFrameImage(uiImage))
                    
                }
            case .setFrameImage(let image):
                state.selectedFrame = image
                return .none
            }
        }
    }
}
