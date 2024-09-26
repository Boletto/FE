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
    struct State: Equatable {
        var travelId: Int
        var photoGridState: PhotoGridFeature.State = .init()
        var stickersState: StickersFeature.State = .init()
        var stickerPickerState: StickerPickerFeature.State = .init()
        var selectedPhoto: [PhotosPickerItem] = []
        var editMode: Bool = false
        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<Action.Alert>?
    }

    enum Action: BindableAction{
        case binding(BindingAction<State>)
        case photoGridAction(PhotoGridFeature.Action)
        case stickersAction(StickersFeature.Action)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<Alert>)
        case changeEditMode
        case showStickerPicker
        case showDeleteAlert
        case updateSelectedPhotos([PhotosPickerItem])
        case fetchMemory
//        case fetchMemory
        enum Alert: Equatable {
            case deleteButtonTapped
        }
    }

    @Reducer(state: .equatable)
    enum Destination {
        case fourCutPicker(AddFourCutFeature)
        case photoPicker
        case stickerPicker(StickerPickerFeature)
    }
    @Dependency(\.travelClient) var travelClient
    var body: some ReducerOf<Self> {
        Scope(state: \.photoGridState, action: \.photoGridAction) {
            PhotoGridFeature()
        }
        Scope(state: \.stickersState, action: \.stickersAction) {
            StickersFeature()
        }
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .changeEditMode:
                if state.editMode {
                    state.editMode.toggle()
                    return .send(.stickersAction(.unselectSticker))
                }
                state.editMode.toggle()
                return .none
            case .destination(.presented(.fourCutPicker(.fourCutAdded(let index, let image)))):
                return .send(.photoGridAction(.updatePhoto(image: Image(uiImage: image) )))
            case .destination(.presented(.stickerPicker(.addSticker(let sticker)))):
                return .send(.stickersAction(.addSticker(sticker)))
            case .photoGridAction(.confirmationDialog(.presented(.fourCutTapped))):
                state.destination = .fourCutPicker(AddFourCutFeature.State(travelID: state.travelId, pictureIndex: state.photoGridState.selectedIndex!))
                return .none
            case .photoGridAction(.confirmationDialog(.presented(.polaroidTapped))):
                state.destination = .photoPicker
                return .none
            case .showStickerPicker:
                state.destination = .stickerPicker(StickerPickerFeature.State())
                return .none
            case .showDeleteAlert:
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
                return .send( .photoGridAction(.deletePhoto))
            case .updateSelectedPhotos(let photos):
                return .run {send in
                    if let photo = photos.first, let data = try? await photo.loadTransferable(type: Data.self), let uiimage = UIImage(data: data) {
                        await send(.photoGridAction(.updatePhoto( image: Image(uiImage: uiimage))))
                    }
                }
            case .fetchMemory:
                let travelid = state.travelId
                return .run { send in
                    let data = try await travelClient.getSingleMemory(travelid)
                    print(data)
                }
            case .destination, .photoGridAction, .stickersAction, .alert:
                return .none
            }}
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
}
