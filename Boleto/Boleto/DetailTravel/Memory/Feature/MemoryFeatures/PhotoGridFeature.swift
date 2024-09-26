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
        var photos: [PhotoItem?] = Array(repeating: nil, count: 6)
        var selectedFullScreenImage: Image?
        var selectedIndex: Int?
        @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    }

    enum Action: Equatable {
        case addPhotoTapped(index: Int)
        case updatePhoto(image: Image)
        case deletePhoto
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case clickFullScreenImage(Int)
        case dismissFullScreenImage
        case clickEditImage(Int)
//        case addFourCutPhoto(Int, Image)
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
                    title: TextState("Add Photo"),
                    message: TextState("Choose photo type"),
                    buttons: [
                        .default(TextState("Four Cut"), action: .send(.fourCutTapped)),
                        .default(TextState("Polaroid"), action: .send(.polaroidTapped)),
                        .cancel(TextState("Cancel")),
                    ]
                )
                return .none
                
            case .updatePhoto( let image):
                guard let selectedIndex = state.selectedIndex else {return .none}
                if selectedIndex < state.photos.count {
                    state.photos[selectedIndex] = PhotoItem(image: image, type: .polaroid)
                } else {
                    state.photos.append(PhotoItem(id: UUID(), image: image, type: .polaroid))
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
                state.selectedFullScreenImage = state.photos[index]?.image
                state.selectedIndex = index
                return .none
            case .dismissFullScreenImage:
                state.selectedFullScreenImage = nil
                state.selectedIndex = nil
                return .none
            case .clickEditImage(let index):
                state.selectedIndex = index
                return .none
//            case .addFourCutPhoto(let index, let image):
//                if index < state.photos.count {
//                    state.photos[index] = PhotoItem(image: image,type: .fourCut)
//                } else {
//                    state.photos.append(p)
//                }

            }
        }
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
    }
}
