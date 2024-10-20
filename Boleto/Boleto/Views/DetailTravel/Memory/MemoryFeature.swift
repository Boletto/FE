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
        
        var color: TicketColor
        var photoGridState: PhotoGridFeature.State
        var stickersState: StickerManagementFeature.State = .init()
        var stickerPickerState: StickerPickerFeature.State = .init()
        var selectedPhoto: [PhotosPickerItem] = []
        var editMode: Bool = false
        var isLocked: Bool = false
        @Shared(.appStorage("userID")) var userid  = 0
        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<Action.Alert>?
        init(travelId: Int, ticketColor: TicketColor) {
            self.travelId = travelId
            self.color = ticketColor
            self.photoGridState = PhotoGridFeature.State(travelID: travelId)
            
        }
    }
    
    enum Action: BindableAction{
        case binding(BindingAction<State>)
        case photoGridAction(PhotoGridFeature.Action)
        case stickersAction(StickerManagementFeature.Action)
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
        case captureGridContent(UIImage?)
        case issuccessSave(Bool)
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
    @Dependency(\.photoLibrary) var photoLibrary
    var body: some ReducerOf<Self> {
        Scope(state: \.photoGridState, action: \.photoGridAction) {
            PhotoGridFeature()
        }
        Scope(state: \.stickersState, action: \.stickersAction) {
            StickerManagementFeature()
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
  
                        if let compressedData = uiImage.jpegData(compressionQuality: 0.3) {
                            let (photoId, photoUrl) = try await travelClient.postSinglePhoto( travelId, selectedIndex, compressedData)
                            let photoItem = PhotoItem(id: photoId, image: Image(uiImage: uiImage), pictureIdx: selectedIndex, imageURL: photoUrl)
                            await send(.photoGridAction(.updatePhoto(photoItem: PhotoGridItem.singlePhoto(photoItem))))
                            
                        }
                        
                    } catch {
                        print("Error processing photo: \(error)")
                    }
                }
            case let .updateMemory(fourcuts, photos, stickers, isLocked):
                state.stickersState.stickers = IdentifiedArray(uniqueElements: stickers)
                let highestIndex = photos.map{$0.pictureIdx}.max() ?? 6
                let nextMultipleOfSix = ((highestIndex + 5) / 6) * 6 // 6의 배수로 올림
                var  newphotos:[PhotoGridItem?] = Array(repeating: nil, count: max(nextMultipleOfSix, 6) )
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
            case .captureGridContent(let image):
                guard let image = image else {return .none}
                return .run {send in
                    let result = try await photoLibrary.saveImage(image)
                    
                    await send(.issuccessSave(result))
                    
                }
            case .issuccessSave(let isSuccess):
                state.alert = AlertState(
                    title: TextState(isSuccess ? "저장 완료": "저장 실패"),
                    message: TextState(isSuccess ? "성공적으로 갤러리에 저장되었습니다." : "갤러리 저장 실패했습니다."),
                    dismissButton: .default(TextState("확인"))
                )
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
    
}
