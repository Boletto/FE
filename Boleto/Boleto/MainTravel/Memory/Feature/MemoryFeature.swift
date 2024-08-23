//
//  MemoryFeature.swift
//  Boleto
//
//  Created by Sunho on 8/12/24.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

@Reducer
struct MemoryFeature {
    @ObservableState
    struct State: Equatable{
        var selectedPhotosImages: [Image?] = Array(repeating: nil, count: 6)
        var selectedPhotos: [PhotosPickerItem] = []
        var selectedFullScreenImage: Image?
        var selectedIndex: Int?
        @Presents var destination: Destination.State?
        @Presents var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDaialog>?
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case fourCutFullScreen(AddFourCutFeature)
        case photoPicker
        case stickerHalf
        case messageHalf
//        case fullScreenImage
    }
    
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        case confirmationDialog(PresentationAction<ConfirmationDaialog>)
        case showSticker
        case showMessage
        case confirmationPhotoIndexTapped(Int)
        case updateSelectedPhotos([PhotosPickerItem])
        case updateSelectedImage(Int, Image)
        case clickFullScreenImage(Int)
        case clickEditImage(Int)
        case dismissFullScreenImage
        @CasePathable
        enum ConfirmationDaialog{
            case fourcutTapped
            case polaroidTapped
            
        }
    }
    var body: some ReducerOf<Self> {
        Reduce {state, action in
            switch action {
            case .updateSelectedImage(let index, let image  ):
                state.destination = .none
                state.selectedPhotosImages[index] = image
                state.selectedIndex = nil
                return .none
            case .updateSelectedPhotos(let photos):
                guard let selectedIndex = state.selectedIndex else {return .none}
                state.selectedPhotos = photos
                return .run { send in
                    if let photo = photos.first, let data = try? await photo.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                        await send(.updateSelectedImage(selectedIndex, Image(uiImage: uiImage)))
                    }
                }
            case .confirmationPhotoIndexTapped(let index):
                if state.selectedPhotosImages.count <= index {
                    state.selectedPhotosImages.append(contentsOf: Array(repeating: nil, count: 6))
                }
                state.selectedIndex = index
                state.confirmationDialog = ConfirmationDialogState {
                    TextState("Confirmation")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                    ButtonState(action: .fourcutTapped) {
                        TextState("네컷 사진 추가")
                    }
                    ButtonState(action: .polaroidTapped) {
                        TextState("폴라로이드 사진 추가")
                    }
                } message: {
                    TextState("this is confirmationdIalog")
                }
                return .none
                
            case .destination:
                return .none
            case .confirmationDialog(.presented(.polaroidTapped)):
                state.destination = .photoPicker
                return .none
            case .confirmationDialog(.presented(.fourcutTapped)):
                state.destination = .fourCutFullScreen(AddFourCutFeature.State())
                return .none
            case .confirmationDialog(.dismiss):
                state.destination  = nil
                return .none
            case .showMessage:
                state.destination = .messageHalf
                return .none
            case .showSticker:
                state.destination = .stickerHalf
                return .none
            case .clickFullScreenImage(let index):
                state.selectedFullScreenImage = state.selectedPhotosImages[index]
                return .none
            case .clickEditImage(let index):
                state.selectedIndex = index
                return .none
            case .dismissFullScreenImage:
                state.selectedFullScreenImage  = nil
                return .none
            }
        }.ifLet(\.$confirmationDialog, action: \.confirmationDialog)
            .ifLet(\.$destination, action: \.destination)
    }
}
