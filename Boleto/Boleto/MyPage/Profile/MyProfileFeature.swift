//
//  MyProfileFeature.swift
//  Boleto
//
//  Created by Sunho on 9/12/24.
//

import ComposableArchitecture
import SwiftUI
import PhotosUI
@Reducer
struct MyProfileFeature {
    @Dependency(\.dismiss) var dismiss
    @ObservableState
    struct State: Equatable {
        var nickName: String = ""
        var name: String = ""
        var profileImage: UIImage?
        var isImagePickerPresented: Bool = false
        var selectedItem: PhotosPickerItem?
        @Presents var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        
    }
    enum Action: BindableAction {
        case binding(BindingAction<State> )
        case saveProfile
        case backbuttonTapped
        case imagePickerSelection(PhotosPickerItem?)
        case setProfileImage(UIImage?)
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case tapProfile
        enum ConfirmationDialog: Equatable {
            case changetoDefault
            case photoPicker
        }
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {state, action in
            switch action {
            case .binding(\.selectedItem):
                guard let selectedItem = state.selectedItem else {return .none}
                return .run { send in
                    let data = try await selectedItem.loadTransferable(type: Data.self)
                    guard let data = data, let uiImage = UIImage(data: data) else { return }
                    await send(.setProfileImage(uiImage))
                }
            case .binding:
                return .none
            case .saveProfile:
                return .none
            case .confirmationDialog(.presented(.changetoDefault)):
                state.profileImage = nil
                return .none
            case .confirmationDialog(.presented(.photoPicker)):
                state.isImagePickerPresented = true
                return .none
            case .confirmationDialog:
                return .none
            case .tapProfile:
                state.confirmationDialog = ConfirmationDialogState(
                    title: TextState("Add"),
                    buttons: [
                        .default(TextState("기본 프로필로 전환"), action: .send(.changetoDefault)),
                        .default(TextState("갤러리에서 사진 선택").foregroundColor(.black), action: .send(.photoPicker)),
                        .cancel(TextState("닫기").foregroundColor(.black)),
                    ]
                )
                return .none
            case .backbuttonTapped:
                return .run { _ in await self.dismiss() }
            case let .imagePickerSelection(item):
                state.selectedItem = item
                guard let item = item else { return .none }
                return .run { send in
                    let data = try await item.loadTransferable(type: Data.self)
                    guard let data = data, let uiImage = UIImage(data: data) else { return }
                    await send(.setProfileImage(uiImage))
                }
            case .setProfileImage(let image):
                state.profileImage = image
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
    }
}
