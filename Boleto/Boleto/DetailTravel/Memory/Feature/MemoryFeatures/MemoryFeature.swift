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
        case updateMemory([FourCutModel],[PhotoItem], [Sticker], Bool)
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
                let editMode = state.editMode
                let stickers = state.stickersState.stickers
                return .run { send in
                    // editMode에서 넘어갈때는 리스트 채워줘야함.
                    let response =  try await travelClient.patchMemory(travelId, editMode, stickers)
                    if response {
                        await send(.toggleLock)
                    }
                }
            case .destination(.presented(.fourCutPicker(.successUpload(let photoItem)))):
                state.photoGridState.photos[photoItem.index] = .fourCut(photoItem)
                //TODO: 해야함 이벤트 사진네컷추가햇을때
                state.destination = nil
                return .none
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
                guard let photo = photos.first else {return .none}
                let travelId = state.travelId
                let selectedIndex = state.photoGridState.selectedIndex!
                return .run { send in
                    do {
                        let data = try await photo.loadTransferable(type: Data.self)
                        guard let uiImage = UIImage(data: data!) else { throw NSError(domain: "Image conversion failed", code: 0) }
//                        
//                        // PolaroidView를 생성하고 캡처
////                        let polaroidImage = await capturePolaroidView(image: Image(uiImage: uiImage))
//                        if let compressedData = uiImage.jpegData(compressionQuality: 0.3) {
//                            let (photoId, photoUrl) = try await travelClient.postSinglePhoto( travelId, selectedIndex, compressedData)
//                            let photoItem = PhotoItem(id: photoId, image: Image(uiImage: uiImage), pictureIdx: selectedIndex, imageURL: photoUrl)
////                            await send(.photoGridAction(.updatePhoto(photoItem: photoItem)))
//
//                        }
                        
                    } catch {
                        print("Error processing photo: \(error)")
                    }
                }
            case let .updateMemory(fourcuts, photos, stickers, isLocked):
                state.stickersState.stickers = IdentifiedArray(uniqueElements: stickers)
                let highestIndex = photos.map{$0.pictureIdx}.max() ?? 6
                let nextMultipleOfSix = ((highestIndex + 5) / 6) * 6 // 6의 배수로 올림
                var  newphotos:[PhotoGridItem?] = Array(repeating: nil, count: nextMultipleOfSix)
                for photo in photos {
                    newphotos[photo.pictureIdx] = PhotoGridItem.singlePhoto(photo)
                }
                for fourcut in fourcuts {
                    newphotos[fourcut.index] = PhotoGridItem.fourCut(fourcut)
                }
                state.photoGridState.photos = newphotos
                state.isLocked = isLocked
                return .none
            case .fetchMemory:
                let travelid = state.travelId
                return .run { send in
                    let (fourcuts, photos,stickers,isLocked) = try await travelClient.getSingleMemory(travelid)
                    await send(.updateMemory(fourcuts, photos, stickers, isLocked))
                    if isLocked {
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
