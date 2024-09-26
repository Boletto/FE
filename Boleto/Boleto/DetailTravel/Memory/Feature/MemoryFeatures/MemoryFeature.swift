//
//  MemoryFeature.swift
//  Boleto
//
//  Created by Sunho on 8/12/24.
//d

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
        var isLocked: Bool = false
        @Shared(.appStorage("userID")) var userid  = 0
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
        case showisLockedAlert
        case updateSelectedPhotos([PhotosPickerItem])
        case fetchMemory
        case toggleLock

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
            case .toggleLock:
                state.editMode.toggle()
                state.isLocked.toggle()
                return .send(.stickersAction(.unselectSticker))
            case .changeEditMode:
                let travelId = state.travelId
                let userId = state.userid
                let editMode = state.editMode
                let stickers = state.stickersState.stickers
                return .run { send in
                    // editMode에서 넘어갈때는 리스트 채워줘야함.
                    let response =  try await travelClient.patchMemory(travelId, userId, editMode, stickers)
                    if response {
                        await send(.toggleLock)
                    }
                }
            case .destination(.presented(.fourCutPicker(.fourCutAdded(let image)))):
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
            case .showisLockedAlert:
                state.alert = AlertState {
                    TextState("지금은 편집할 수 없어요.")
                } actions : {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState("친구가 추억 편집을 완료할 때까지 잠시만 기다려주세요.")
                }
                return .none
            case .alert(.presented(.deleteButtonTapped)):
                return .send( .photoGridAction(.deletePhoto))
            case .updateSelectedPhotos(let photos):
                let userId = state.userid
                let travelId = state.travelId
                let selectedIndex = state.photoGridState.selectedIndex!
                return .run {send in
                    if let photo = photos.first,
                       let data = try? await photo.loadTransferable(type: Data.self),
                       let uiimage = UIImage(data: data) {
                        // 이미지 압축
                        if let compressedData = uiimage.jpegData(compressionQuality: 0.2) { // 압축 비율을 적절히 조절
                            let response = try await travelClient.postSinglePhoto(userId, travelId, selectedIndex, compressedData)
                            if response {
                                await send(.photoGridAction(.updatePhoto(image: Image(uiImage: uiimage))))
                            }
                        }
                    }
                }
            case .fetchMemory:
                let travelid = state.travelId
                return .run { send in
                    let memoryData = try await travelClient.getSingleMemory(travelid)
                        //이거때문에 생기는듯?
//                    memoryData
                    if memoryData.status == "Lock" {
                        await send(.showisLockedAlert)
                    }
                }
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
}
