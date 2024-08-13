//
//  MemoryView.swift
//  Boleto
//
//  Created by Sunho on 8/12/24.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

struct MemoriesView: View {
    @Bindable var store: StoreOf<MemoryFeature>
    var columns: [GridItem] = [GridItem(.flexible(),spacing:  16), GridItem(.flexible())]
    var rotations: [Double] = [-5, 5, 5, -5, -5, 5, -5, 5, -5, 5]
    var body: some View {
        ZStack {
            LazyVGrid(columns: columns, spacing: 40) {
                ForEach(0..<6) {index in
                    if let image = store.selectedPhotosImages[index] {
                        PolaroaidView(imageView: image)
                            .frame(height: 160)
                            .onTapGesture {
                                print("toich")
                            }
                            .rotationEffect(Angle(degrees: rotations[index % rotations.count]))
                    } else {
                        EmptyPhotoView()
                            .frame(height: 160)
                            .onTapGesture {
                                store.send(.confirmationPhotoIndexTapped(index))
                            }.rotationEffect(Angle(degrees: rotations[index]))
                    }
                }
            }.padding(.horizontal, 16)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.pink.opacity(0.4))
            .clipShape(.rect(cornerRadius: 30))
            .padding()
            .confirmationDialog($store.scope(state: \.confirmationDialog, action: \.confirmationDialog))
            .sheet(item: $store.scope(state: \.destination?.fourCutFullScreen, action: \.destination.fourCutFullScreen)) {
                store in
            }
            .photosPicker(isPresented: Binding(get: {store.destination == .photoPicker}, set: {_ in}), selection: $store.selectedPhotos.sending(\.updateSelectedPhotos),
                          maxSelectionCount: 1,
                          matching: .images)
    }
}

#Preview {
    MemoriesView(store: Store(initialState: MemoryFeature.State()) {
        MemoryFeature()
    })
}
