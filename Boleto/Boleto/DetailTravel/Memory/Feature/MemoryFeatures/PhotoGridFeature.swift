//
//  PhotoGridFeature.swift
//  Boleto
//
//  Created by Sunho on 8/30/24.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

@Reducer
struct PhotoGridFeature {
    struct State: Equatable {
        var photos: [PhotoGridItem?] = Array(repeating: nil, count: 6)
        var selectedFullScreenItem: PhotoGridItem?
        var selectedIndex: Int?
        @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    }

    enum Action: Equatable {
        case addPhotoTapped(index: Int)
        case updatePhoto(photoItem: PhotoGridItem)
        case deletePhoto
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case clickFullScreenImage(Int)
        case dismissFullScreenImage
        case clickEditImage(Int)
        enum ConfirmationDialog: Equatable {
            case fourCutTapped
            case polaroidTapped
        }
    }
    @Dependency(\.travelClient) var travelClient
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addPhotoTapped(let index):
                state.selectedIndex = index
                state.confirmationDialog = ConfirmationDialogState(
                    title: TextState("Add"),
                    buttons: [
                        .default(TextState("네컷사진 추가"), action: .send(.fourCutTapped)),
                        .default(TextState("폴라로이드 사진 추가").foregroundColor(.black), action: .send(.polaroidTapped)),
                        .cancel(TextState("닫기").foregroundColor(.black)),
                    ]
                )
                return .none
                
            case .updatePhoto( let photoItem):
                guard let selectedIndex = state.selectedIndex else {return .none}
                if selectedIndex < state.photos.count {
                    state.photos[selectedIndex] = photoItem
//                    state.photos[selectedIndex] = PhotoItem(image: image,pictureIdx: selectedIndex)
                } else {
                    state.photos.append(photoItem)
//                    state.photos.append(PhotoItem(id: UUID(), image: image, pictureIdx: selectedIndex))
                }
                return .none
                
            case .deletePhoto:
                guard let selectedIndex = state.selectedIndex else {return .none}
//                state.photos[selectedIndex]
                state.photos[selectedIndex] = nil
//                let photoId = state.photos[selectedIndex].
                return .run { send in
//                    travelClient.deleteSinglePhoto()
                }
               
                return .none
            case .confirmationDialog:
                return .none
            case .clickFullScreenImage(let index):
          if let photo = state.photos[index] {
                state.selectedFullScreenItem = photo
                state.selectedIndex = index
            }
                return .none
            case .dismissFullScreenImage:
                state.selectedFullScreenItem = nil
                state.selectedIndex = nil
                return .none
            case .clickEditImage(let index):
                state.selectedIndex = index
                return .none

            }
        }
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
    }
}
