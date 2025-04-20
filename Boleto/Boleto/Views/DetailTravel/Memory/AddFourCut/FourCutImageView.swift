//
//  FourCutImageView.swift
//  Boleto
//
//  Created by Sunho on 8/17/24.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI

struct FourCutImageView: View {
    @Bindable var store: StoreOf<AddFourCutFeature>
    
    @State private var selectedImage: UIImage?
    let index: Int
    var body: some View {
        ZStack {
            if let image = store.fourCutImages[index] {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 122,height: 122)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(Color.white.opacity(1))
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray))
                    .frame(width: 122, height: 122)
                Circle()
                    .fill(Color.gray1.opacity(0.5))
                    .frame(width: 32, height: 32)
                    .overlay(Image(systemName: "plus").foregroundStyle(.white).font(.system(size: 24)))
            }
            PhotosPicker(selection: Binding(
                get: { store.selectedPhotos[index] },
                set: { newValue in
                    if let newValue = newValue {
                        Task {
                            if let data = try? await newValue.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                self.selectedImage = image
                            }
                        }
                    }
                }
            ), matching: .images) {
                Color.clear
            }
            
        }.frame(width: 122,height: 122)
            .sheet(isPresented: Binding(
                get: { selectedImage != nil },
                set: { _ in selectedImage = nil }
            )) {
                if let selectedImage {
//                    ImageEditorView(store: <#StoreOf<ImageEditorFeature>#>, image: selectedImage) { cropImage in
//                        store.send(.loadPhoto(index, cropImage))
//                    }
//                    .background(Color.modal.ignoresSafeArea())
                }
            }
        
    }
}

//#Preview {
//    FourCutImageView(store: .init(initialState: AddFourCutFeature.State(), reducer: {
//        AddFourCutFeature()
//    }), index: 1)
//}
