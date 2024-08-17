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
    @State var editMode  = false
    var columns: [GridItem] = [GridItem(.flexible(),spacing:  16), GridItem(.flexible())]
    var rotations: [Double] = [-5, 5, 5, -5, -5, 5, -5, 5, -5, 5]
    var body: some View {
        ZStack (alignment: .bottomTrailing){
            ZStack {
                LazyVGrid(columns: columns, spacing: 32) {
                    ForEach(0..<6) {index in
                        if let image = store.selectedPhotosImages[index] {
                            PolaroaidView(imageView: image)
                                .frame(height: 160)
                                .onTapGesture {
                                    print("touch")
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
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .frame(height: 600)
                .background(Color.customGray1)
                .clipShape(.rect(cornerRadius: 30))
            }.padding(.horizontal, 32)
            
            VStack {
                FloatingButton(symbolName: editMode ? "message" : "square.and.arrow.up") {
                    if editMode {
                        store.send(.showSticker)
                    }
                }
                FloatingButton(symbolName: editMode ? "figure.gymnastics" : "pencil") {
                    editMode.toggle()
                }
            }.padding()
        }.confirmationDialog($store.scope(state: \.confirmationDialog, action: \.confirmationDialog))
            .fullScreenCover(item: $store.scope(state: \.destination?.fourCutFullScreen, action: \.destination.fourCutFullScreen)) { store in
                AddFourCutView().applyBackground()
            }
       
            .sheet(item: $store.scope(state: \.destination?.stickerHalf, action: \.destination.stickerHalf), content: { store in
                StickerView()
                    .presentationDetents([.medium, .large])
            })
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
