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

    }
    enum Action: BindableAction {
        case binding(BindingAction<State> )
        case saveProfile
        case backbuttonTapped
        case imagePickerSelection(PhotosPickerItem?)
           case setProfileImage(UIImage?)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {state, action in
            switch action {
            case .binding:
                return .none
            case .saveProfile:
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
                
            }
        }
        
    }
}
