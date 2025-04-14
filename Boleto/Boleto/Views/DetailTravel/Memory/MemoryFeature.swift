//
//  MemoryFeature.swift
//  Boleto
//
//  Created by Sunho on 8/12/24.
//d

import SwiftUI
import PhotosUI
import ComposableArchitecture
//MARK: 리팩해보자 변수가 넘많음
@Reducer
struct MemoryFeature {
    @ObservableState
    struct State: Equatable {
        var travelId: Int
        var ticketFullURL: String
        var photoGridState: PhotoGridFeature.State
        var stickersState: StickerManagementFeature.State = .init()
        var stickerPickerState: StickerPickerFeature.State = .init()
        var selectedPhoto: [PhotosPickerItem] = []
        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<Action.Alert>?
        var stickers: [StickerItem] { stickersState.stickers.elements }
        var speechs: [SpeechItem] { stickersState.speechs.elements }
        var editStatus: EditState

        var selectedUiimage: UIImage?
        
        
        init(travelId: Int, editStatus: EditState, ticketfullurl: String) {
            self.travelId = travelId
            self.photoGridState = PhotoGridFeature.State(travelID: travelId)
            self.editStatus = editStatus
            self.ticketFullURL = ticketfullurl
        }
    }
    
    
    enum Action: BindableAction, Equatable{
        case binding(BindingAction<State>)
        case photoGridAction(PhotoGridFeature.Action)
        case stickersAction(StickerManagementFeature.Action)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<Alert>)
        case onTapEditMode
        case changeEditStatus(EditState)
        
        case showImageEditor(UIImage)
        case imageEditorComplete(UIImage?)
        case showStickerPicker
        case showDeleteAlert
        case showisLockedAlert
        case showAlert(String)
        case updateSelectedPhotos([PhotosPickerItem])
        case fetchMemory
        
        case shareToInstagramStory(UIImage?)
        case sessionExpired
        enum Alert: Equatable {
            case deleteButtonTapped
        }
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case fourCutPicker(AddFourCutFeature)
        case photoPicker
        case stickerPicker(StickerPickerFeature)
        
        enum Action: Equatable {
            case fourCutPicker(AddFourCutFeature.Action)
            case photoPicker
            case stickerPicker(StickerPickerFeature.Action)
        }
    }
    
    @Dependency(\.travelClient) var travelClient
    @Dependency(\.memoryClient ) var memoryClient
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
            case .photoGridAction(.confirmationDialog(.presented(.fourCutTapped))):
                state.destination = .fourCutPicker(AddFourCutFeature.State(travelID: state.travelId, pictureIndex: state.photoGridState.selectedIndex!.linearIndex))
                return .none
            case .photoGridAction(.confirmationDialog(.presented(.polaroidTapped))):
                state.destination = .photoPicker
                return .none
            case .changeEditStatus(let editstate):
                switch editstate {
                case .unlocked:
                    state.photoGridState.selectedIndex = nil
                default:
                    break
                }
                state.editStatus = editstate
                return .none
                
            case .onTapEditMode:
                switch state.editStatus {
                case .lockedByMe:
                    return .run { [travelID = state.travelId, stickers = state.stickers, speechs = state.speechs.filter { !$0.text.isEmpty }] send in
                        do {
                            try await memoryClient.putStickers(stickers, speechs, travelID)
                            try await travelClient.putEditmodeTravel("UNLOCK",travelID)
                            await send(.stickersAction(.unselectSticker))
                            await send(.changeEditStatus(.unlocked))
                        }  catch let error as CustomError {
                            // 에러 처리: 필요 시 에러를 디스패치하거나 로깅
                            switch error {
                            case .expiredRefreshToken:
                                await send(.sessionExpired)
                                
                            default:
                                print(error.localizedDescription)
                            }
                        }
                    }
                case .unlocked:
                    return .run { [travelID = state.travelId] send in
                        do {
                            try await travelClient.putEditmodeTravel("LOCK",travelID)
                            await send(.changeEditStatus(.lockedByMe))
                        } catch let error as CustomError {
                            // 에러 처리: 필요 시 에러를 디스패치하거나 로깅
                            switch error {
                            case .expiredRefreshToken:
                                await send(.sessionExpired)
//                            case .badRequest(let _, let code):
//                                if code == 40304 {
//                                    try await travelClient.putEditmodeTravel("UNLOCK",travelID)
//                                    await send(.stickersAction(.unselectSticker))
//                                    await send(.changeEditStatus(.unlocked))
//                                }
                            case .accessDenied:
                                await send(.showisLockedAlert)
                                await send(.changeEditStatus(.lockedByOthers))
                            default:
                                await send(.showAlert(error.message))
                            }
                        }
                    }
                case .lockedByOthers:
                    return .send(.showisLockedAlert)
                }
                
                
            case .sessionExpired:
                return .none
            case .destination(.presented(.fourCutPicker(.successUpload))):
                state.destination = nil
                state.editStatus = .lockedByMe
                return .run { send in
                    await send(.fetchMemory)
                }
            case .destination(.presented(.fourCutPicker(.failAlreadyLocked))):
                state.destination = nil
                return .run { send in
                    await send(.showisLockedAlert)
                }
            case .destination(.presented(.stickerPicker(.addSticker(let sticker)))):
                return .send(.stickersAction(.addSticker(sticker)))
            case .destination(.presented(.fourCutPicker(.sessionExpired))):
                return .send(.sessionExpired)
            case .destination(.presented(.fourCutPicker(.showAlert(let message)))):
                return .send(.showAlert(message))
            case .showStickerPicker:
                state.destination = .stickerPicker(StickerPickerFeature.State())
                return .none
            case .showAlert(let message):
                state.alert = AlertState {
                    TextState("에러")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(message)
                }
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
             
                
                return .run { send in
              
                        if let imageData = try await photo.loadTransferable(type: Data.self), let uiimage = UIImage(data: imageData) {
                            await send(.showImageEditor(uiimage))
                        }
                  
                }
            case .showImageEditor(let image):
                state.selectedUiimage = image
                return .none
            case .imageEditorComplete(let editedImage):
                let travelId = state.travelId
                let selectedIndex = state.photoGridState.selectedIndex!.linearIndex
                guard let editedImage = editedImage,
                      let imageData = editedImage.jpegData(compressionQuality: 0.8) else { return .none }
                return .run { send in
                    do {
                        try await memoryClient.postCreateTravelMemory(
                            travelId,
                            selectedIndex,
                            "PICTURE",
                            "NO02",
                            [imageData]
                        )
                        await send(.fetchMemory)
                        await send(.changeEditStatus(.lockedByMe))
                    } catch let error as CustomError {
                        switch error {
                   
                        case .expiredRefreshToken:
                            await send(.sessionExpired)
                        case .accessDenied:
                            await send(.showisLockedAlert)
                        default:
                            await send(.showAlert(error.message))
                        }
                     
                    }
                }
            case .fetchMemory:
                state.selectedUiimage = nil
                return .run {[travelId = state.travelId] send in
                    do {
                        let (singlePhotos, fourCuts, stickers, speechs,isLocked) = try await memoryClient.getTravelMemory(travelId)
                        let updatedPhotos = organizePhotos(singlePhotos: singlePhotos, fourCuts: fourCuts)
                        await send(.photoGridAction(.updatePhotos(updatedPhotos)))
                        await send(.stickersAction(.setStickers(stickers, speechs)))
                    } catch let error as CustomError {
                        switch error {
                   
                        case .expiredRefreshToken:
                            await send(.sessionExpired)
                        default:
                            await send(.showAlert(error.message))
                        }
                     
                    }
                    
                }
            case .photoGridAction(.successDelete):
                return .run { send in
                    await send(.fetchMemory)
                }
                
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
    
    func organizePhotos(singlePhotos: [SinglePhotoItem], fourCuts: [FourCutItem]) -> [[PhotoGridItem?]] {
        // 사진과 네컷 데이터를 정렬하여 그리드로 변환
        let maxIndex = max(
            singlePhotos.map(\.pictureIdx).max() ?? 0,
            fourCuts.map(\.index).max() ?? 0
        )
        let requiredRows = (maxIndex / 6) + 1
        
        // 빈 그리드 생성
        var grid = Array(repeating: Array(repeating: nil as PhotoGridItem?, count: 6), count: requiredRows)
        
        // 일반 사진 배치
        for photo in singlePhotos {
            let index = GridIndex(photo.pictureIdx)
            grid[index.row][index.col] = .singlePhoto(photo)
        }
        
        // 네컷 사진 배치
        for fourCut in fourCuts {
            let index = GridIndex(fourCut.index)
            grid[index.row][index.col] = .fourCut(fourCut)
        }
        
        return grid
    }
}
