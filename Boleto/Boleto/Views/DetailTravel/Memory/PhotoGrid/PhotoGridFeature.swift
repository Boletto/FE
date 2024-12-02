//
//  PhotoGridFeature.swift
//  Boleto
//
//  Created by Sunho on 8/30/24.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

struct GridIndex: Equatable {
    let row: Int
    let col: Int
    var linearIndex: Int {
        return row * 6 + col
    }
    
    init(_ linearIndex: Int) {
        self.row = linearIndex / 6    // `row`는 `linearIndex`를 6으로 나눈 몫
        self.col = linearIndex % 6    // `col`은 `linearIndex`를 6으로 나눈 나머지
    }
}
@Reducer
struct PhotoGridFeature {
    struct State: Equatable {
        var travelID: Int
        var photos: [[PhotoGridItem?]] = [Array(repeating: nil, count: 6)]
        var selectedFullScreenItem: PhotoGridItem?
        var selectedIndex: GridIndex?
        @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    }
    
    enum Action: Equatable {
        case addPhotoTapped(GridIndex)
        case updatePhotos([[PhotoGridItem?]])
        case deletePhoto
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case clickFullScreenImage(GridIndex)
        case dismissFullScreenImage
        case clickEditImage(GridIndex)
        case successDelete

        enum ConfirmationDialog: Equatable {
            case fourCutTapped
            case polaroidTapped
        }
    }
    @Dependency(\.memoryClient) var memoryClient
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addPhotoTapped(let gridIndex):
                state.selectedIndex = gridIndex
                state.confirmationDialog = ConfirmationDialogState(titleVisibility: .visible) {
                    TextState("추가하기")
                } actions: {
                    ButtonState(action: .fourCutTapped){
                        TextState("네컷사진 추가")
                    }
                    ButtonState(action: .polaroidTapped) {
                        TextState("폴라로이드 사진 추가")
                    }
                    ButtonState(role:.cancel){
                        TextState("닫기")
                    }
                }
                
                return .none
                
            case .updatePhotos( let photoItems):
                state.photos = photoItems
                return .none
                
            case .deletePhoto:
                guard let selectedIndex = state.selectedIndex, let selectedPhoto = state.photos[selectedIndex.row][selectedIndex.col]  else { return .none}
                return .run { [travelId = state.travelID, index = selectedIndex.linearIndex] send in
                    try await memoryClient.deleteMemoryItem(travelId,index )
//                    let result = try await travelClient.deleteSinglePhoto(travelId,selectedIndex.linearIndex,isFourCut)
//                    if result{
//                        await send(.successDelete)
//                    }
                }
            case .successDelete:
                guard let selectedIndex = state.selectedIndex else  {return .none}
                state.photos[selectedIndex.row][selectedIndex.col] = nil
                return .none
            case .confirmationDialog:
                return .none
            case .clickFullScreenImage(let index):
                if let photo = state.photos[index.row][index.col] {
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
