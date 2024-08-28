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
        var stickerFeature: StickerFeature.State = StickerFeature.State()
        @Presents var destination: Destination.State?
        @Presents var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDaialog>?
        @Presents var alert: AlertState<Action.Alert>?
        var stickers: [Sticker] = []
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case fourCutFullScreen(AddFourCutFeature)
        case photoPicker
        case stickerHalf(StickerFeature)
        case messageHalf
    }
    
    
    enum Action: BindableAction {
        case binding(BindingAction<State>) 
        case destination(PresentationAction<Destination.Action>)
        case confirmationDialog(PresentationAction<ConfirmationDaialog>)
        case alert(PresentationAction<Alert>)
        case showSticker
        case showMessage
        case confirmationPhotoIndexTapped(Int)
        case updateSelectedPhotos([PhotosPickerItem])
        case updateSelectedImage(Int, Image)
        case clickFullScreenImage(Int)
        case clickEditImage(Int)
        case dismissFullScreenImage
        case showdeleteAlert
        case stickerFeature(StickerFeature.Action)
        case addSticker(Sticker)
        case moveSticker(id: UUID, to: CGPoint)
        case removeSticker(id: UUID)
        @CasePathable
        enum Alert {
            case deleteButtonTapped
        }
        @CasePathable
        enum ConfirmationDaialog{
            case fourcutTapped
            case polaroidTapped
            
        }
    }
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {state, action in
            switch action {
            case .binding:
                return .none
            case let .addSticker(sticker):
                          state.stickers.append(sticker)
                          return .none
            case let .moveSticker(id, to):
                  if let index = state.stickers.firstIndex(where: { $0.id == id }) {
                      state.stickers[index].position = to
                  }
                  return .none
              case let .removeSticker(id):
                  state.stickers.removeAll { $0.id == id }
                  return .none
            case .destination(.presented(.stickerHalf(.addSticker(let sticker)))):
                      let newSticker = Sticker(id: UUID(), image: sticker, position: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2))
                      return .send(.addSticker(newSticker))
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
                state.destination = .stickerHalf(StickerFeature.State())
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
            case .showdeleteAlert:
                state.alert = AlertState {
                    TextState("삭제")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                    ButtonState(action: .deleteButtonTapped) {
                        TextState("삭제")
                    }
                    
                } message: {
                    TextState("이 사진을 삭제하시겠습니까?")
                }
                return .none
            case .alert(.presented(.deleteButtonTapped)):
                return .none
            case .alert:
                return .none
            case .stickerFeature:
                return .none
                
  
            }
        }.ifLet(\.$confirmationDialog, action: \.confirmationDialog)
            .ifLet(\.$destination, action: \.destination)
            .ifLet(\.$alert, action: \.alert)
    }
}
