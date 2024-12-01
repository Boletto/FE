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
        
        var stikerItems: [StickerItem] = []
        var speechItems: [SpeechItem] = []

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
    
    enum Action: BindableAction, Equatable{
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
         
         enum Action: Equatable {
             case fourCutPicker(AddFourCutFeature.Action)
             case photoPicker
             case stickerPicker(StickerPickerFeature.Action)
         }
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
//                let stickers = state.stickersState.stickers
                return .run { send in
                    // editMode에서 넘어갈때는 리스트 채워줘야함.
//                    let response =  try await travelClient.patchMemory(travelId, editMode, stickers)
//                    if response {
                        await send(.toggleLock)
//                    }
                }
            case .destination(.presented(.fourCutPicker(.successUpload(let photoItem)))):
                let index = GridIndex(photoItem.index)
                state.photoGridState.photos[index.row][index.col] = .fourCut(photoItem)
                state.destination = nil
                return .none
            case .destination(.presented(.stickerPicker(.addSticker(let sticker)))):
                return .send(.stickersAction(.addSticker(sticker)))
            case .photoGridAction(.confirmationDialog(.presented(.fourCutTapped))):
//                state.destination = .fourCutPicker(AddFourCutFeature.State(travelID: state.travelId, pictureIndex: state.photoGridState.selectedIndex!.linearIndex))
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
                return .none
//                return .run { send in
//                    do {
//                        let data = try await photo.loadTransferable(type: Data.self)
//                        guard let uiImage = UIImage(data: data!) else { throw NSError(domain: "Image conversion failed", code: 0) }
//  
//                        if let compressedData = uiImage.jpegData(compressionQuality: 0.3) {
//                            let (photoId, photoUrl) = try await travelClient.postSinglePhoto( travelId, selectedIndex.linearIndex, compressedData)
//                            let photoItem = PhotoItem(id: photoId, image: Image(uiImage: uiImage), pictureIdx: selectedIndex.linearIndex, imageURL: photoUrl)
//                            await send(.photoGridAction(.updatePhoto(photoItem: PhotoGridItem.singlePhoto(photoItem))))
//                            
//                        }
//                        
//                    } catch {
//                        print("Error processing photo: \(error)")
//                    }
//                }
//            case let .updateMemory(fourCuts, photos, stickers, isLocked):
////                state.stickersState.stickers = IdentifiedArray(uniqueElements: stickers)
//                state.isLocked = isLocked
////        // 1. 필요한 그리드 크기 계산
//                let maxPhotoIndex = photos.map(\.pictureIdx).max() ?? 0
//                let maxFourCutIndex = fourCuts.map(\.index).max() ?? 0
//                let maxIndex = max(maxPhotoIndex, maxFourCutIndex)
//                let requiredRows = (maxIndex / 6) + 1
//                // 2. 빈 그리드 초기화
//                              var newPhotos: [[PhotoGridItem?]] = Array(repeating: Array(repeating: nil, count: 6), count: requiredRows)
//                              
//                              // 3. 일반 사진 배치
//                              for photo in photos {
//                                  let gridIndex = GridIndex(photo.pictureIdx)
//                                  // 그리드 범위 체크
//                                  guard gridIndex.row < newPhotos.count, gridIndex.col < 6 else { continue }
//                                  newPhotos[gridIndex.row][gridIndex.col] = .singlePhoto(photo)
//                              }
//                              
//                              // 4. 4컷 사진 배치
//                              for fourCut in fourCuts {
//                                  let gridIndex = GridIndex(fourCut.index)
//                                  // 그리드 범위 체크
//                                  guard gridIndex.row < newPhotos.count, gridIndex.col < 6 else { continue }
//                                  newPhotos[gridIndex.row][gridIndex.col] = .fourCut(fourCut)
//                              }
//                              
//                              // 5. 마지막 줄이 모두 채워져 있다면 새로운 빈 줄 추가
//                              if let lastRow = newPhotos.last,
//                                 lastRow.allSatisfy({ $0 != nil }) {
//                                  newPhotos.append(Array(repeating: nil, count: 6))
//                              }
//                              
//                              // 6. 상태 업데이트
//                              state.photoGridState.photos = newPhotos
//                return .none
            case .fetchMemory:
                return .none
//                return .run {[travelid = state.travelId] send in
//                    let (fourcuts, photos,stickers,isLocked) = try await travelClient.getSingleMemory(travelid)
//                    await send(.updateMemory(fourcuts, photos, stickers, isLocked))
//                    if isLocked {
//                        await send(.showisLockedAlert)
//                    }
//                }
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
