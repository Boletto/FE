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
        self.row = linearIndex / 6
        self.col = linearIndex % 6  
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
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
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
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .addPhotoTapped(let gridIndex):
                state.selectedIndex = gridIndex
         
                state.confirmationDialog = ConfirmationDialogState(titleVisibility: .hidden) {
                    TextState("")
                } actions: {
                    ButtonState(action: .fourCutTapped){
                        TextState("네컷사진 추가")
                            .font(.system(size: 14,weight: .bold))
      
                            .foregroundColor(.blue)
                            
                    }
                    ButtonState(action: .polaroidTapped) {
                        TextState("폴라로이드 사진 추가")
                            .font(.system(size: 14, weight: .bold))
         
                    }
                    ButtonState(role:.cancel){
                        TextState("닫기")
                            .font(.customFont(.partifont, size: 14))
                            .fontWeight(.semibold)
                    }
                }
                
                return .none
                
            case .updatePhotos( let photoItems):
                state.photos = photoItems
                return .none
                
            case .deletePhoto:
                guard let selectedIndex = state.selectedIndex, let _ = state.photos[selectedIndex.row][selectedIndex.col]  else { return .none}
                return .run { [travelId = state.travelID, index = selectedIndex.linearIndex] send in
                    try await memoryClient.deleteMemoryItem(travelId,index )
                    await send(.successDelete)
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
