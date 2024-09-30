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
        var inputnickName: String = ""
        var inputname: String = ""
        var profileImage: UIImage?
        var isImagePickerPresented: Bool = false
        var selectedItem: PhotosPickerItem?
        var mode : Mode = .add
        @Presents var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        @Shared(.appStorage("name")) var name = ""
        @Shared(.appStorage("nickname")) var nickname = ""
        @Shared(.appStorage("profile")) var image = ""
        var disableClickButton = true
        init() {
            self.inputname = name
            self.inputnickName = nickname
        }
        
    }
    enum Mode {
        case add
        case edit
    }
    enum Action: BindableAction {
        case binding(BindingAction<State> )
        case selectMode(mode: Mode)
        case saveProfile
        case backbuttonTapped
        case imagePickerSelection(PhotosPickerItem?)
        case setProfileImage(UIImage?)
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case tapProfile
        case updateUserInfo(name: String, nickname: String, image: String)
        enum ConfirmationDialog: Equatable {
            case changetoDefault
            case photoPicker
        }
    }
    @Dependency(\.userClient) var userClient
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {state, action in
            switch action {
            case .selectMode(let mode):
                state.mode = mode
                return .none
            case .binding(\.selectedItem):
                guard let selectedItem = state.selectedItem else {return .none}
                return .run { send in
                    let data = try await selectedItem.loadTransferable(type: Data.self)
                    guard let data = data, let uiImage = UIImage(data: data) else { return }
                    await send(.setProfileImage(uiImage))
                }
            case .binding(\.inputnickName), .binding(\.inputname):
                      // 입력 값이 변경될 때 버튼 상태 업데이트
                      state.disableClickButton = state.inputnickName.isEmpty || state.inputname.isEmpty
                      return .none
            case .binding:
                return .none
            case .saveProfile:
                guard let photoimage = state.profileImage else {return .none}
                let nickname = state.inputnickName
                let name = state.inputname
                let photodata = photoimage.jpegData(compressionQuality: 0.3)!
                return .run { send in
                    let result = try await userClient.patchUser(photodata, nickname, name)
                    await send(.updateUserInfo(name: result.name, nickname: result.nickName, image: result.profileImage))
                }
            case .confirmationDialog(.presented(.changetoDefault)):
                state.profileImage = nil
                return .none
            case .confirmationDialog(.presented(.photoPicker)):
                state.isImagePickerPresented = true
                return .none
            case .confirmationDialog:
                return .none
            case .updateUserInfo(let name, let nickname, let image):
                state.name = name
                state.nickname = nickname
                state.image = image
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
