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
    var rotations: [Double] = [-4.5, 4.5, 4.5, -4.5, -4.5, 4.5, -4.5, 4.5, -4.5, 4.5]
    var body: some View {
        ZStack (alignment: .bottomTrailing){
            gridContent
            editButtons
        }.confirmationDialog($store.scope(state: \.confirmationDialog, action: \.confirmationDialog))
            .fullScreenCover(item: $store.scope(state: \.destination?.fourCutFullScreen, action: \.destination.fourCutFullScreen)) { store in
                AddFourCutView(store: store).applyBackground()
            }
            .sheet(item: $store.scope(state: \.destination?.stickerHalf, action: \.destination.stickerHalf), content: { store in
                StickerView()
                    .presentationDetents([.medium, .large])
            })
            .photosPicker(isPresented: Binding(get: {store.destination == .photoPicker}, set: {_ in}), selection: $store.selectedPhotos.sending(\.updateSelectedPhotos),
                          maxSelectionCount: 1,
                          matching: .images)
    }
    var gridContent: some View {
        ZStack {
            LazyVGrid(columns: columns, spacing: 32) {
                ForEach(0..<6) {index in
                    gridItem(for: index)}
            }        .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .frame(height: 600)
                .background(Color.customGray1)
                .clipShape(.rect(cornerRadius: 30))
        }
        .padding(.horizontal, 32)
    }
    func gridItem(for index: Int) -> some View {
        Group {
            if let image = store.selectedPhotosImages[index] {
                PolaroaidView(imageView: image)
                    .frame(width: 126, height: 145)
                    .onTapGesture {
                        print("touch")
                    }
            } else {
                EmptyPhotoView()
                    .frame(width: 126, height: 145)
                    .onTapGesture {
                        store.send(.confirmationPhotoIndexTapped(index))
                    }
            }
        }.rotationEffect(Angle(degrees: rotations[index % rotations.count]))
    }
    var editButtons: some View {
           VStack {
               FloatingButton(symbolName: nil,imageName: editMode ? "Sticker" : nil,isEditButton: false) {
                   
               }
               FloatingButton(symbolName: editMode ? nil : "square.and.arrow.up", imageName: editMode ? "ChatsCircle" : nil, isEditButton: false) {
                   if editMode {
                       store.send(.showSticker)
                   }
               }
               FloatingButton(symbolName: editMode ? "checkmark" : nil, imageName: editMode ? nil : "PencilSimple", isEditButton: true) {
                   editMode.toggle()
               }
           }
           .padding()
       }
}

#Preview {
    MemoriesView(store: Store(initialState: MemoryFeature.State()) {
        MemoryFeature()
    })
}
