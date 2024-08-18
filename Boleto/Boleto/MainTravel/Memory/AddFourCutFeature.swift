//
//  AddFourCutFeature.swift
//  Boleto
//
//  Created by Sunho on 8/17/24.
//

import Foundation
import PhotosUI
import ComposableArchitecture
import SwiftUI

@Reducer
struct AddFourCutFeature {
    @ObservableState
    struct State: Equatable {
        var savedImages = ["dong", "gas", "beef", "beef1","beef2","beef3","beef4"]
        var defaultImages = ["beef3","beef4","beef", "beef1","beef2", "dong", "gas"]
        var selectedImage: String?
        var selectedPhotos: [PhotosPickerItem?] = [nil,nil,nil,nil]
        var fourCutImages: [UIImage?] = [nil,nil,nil,nil]
        
        //        @Presents var isPhotoPickerPresented: PhotoPickerState?
    }
  
    enum Action {
        case selectImage(Int, Bool)
        case selectPhoto(Int)
        case loadPhoto(Int, UIImage?)
        
    }
    var body: some ReducerOf<Self> {
        Reduce { state ,action in
            switch action {
            case .selectImage(let index, let isDefault):
                state.selectedImage = isDefault ? state.defaultImages[index] : state.savedImages[index]
                return .none
            case .selectPhoto(let index):
                return .none
            case .loadPhoto(let index, let image):
                state.fourCutImages[index] = image
                return .none
                
            }
        }
    }
   
}

