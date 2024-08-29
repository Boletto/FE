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
    @State var clickImage = false
    @State private var selectedImage: Image? = nil
    @State private var gridFrame: CGRect = .zero
    var columns: [GridItem] = [GridItem(.flexible(),spacing:  16), GridItem(.flexible())]
    var rotations: [Double] = [-4.5, 4.5, 4.5, -4.5, -4.5, 4.5, -4.5, 4.5, -4.5, 4.5]
    var body: some View {
        ZStack (alignment: .bottomTrailing){
            gridContent
                .padding(.horizontal, 32)
            editButtons
            
        }.confirmationDialog($store.scope(state: \.photoGridState.confirmationDialog, action: \.photoGridAction.confirmationDialog))
            .fullScreenCover(item: $store.scope(state: \.destination?.fourCutPicker, action: \.destination.fourCutPicker)) { store in
                AddFourCutView(store: store).applyBackground()
            }
            .sheet(item: $store.scope(state: \.destination?.stickerPicker, action: \.destination.stickerPicker), content: { store in
                StickerView(store: store)
                    .presentationDetents([.medium])
                
            })
            .photosPicker(isPresented: Binding(get: {store.destination == .photoPicker}, set: {_ in store.destination = nil}),
                          selection:  $store.selectedPhoto.sending(\.updateSelectedPhotos),
                                  maxSelectionCount: 1,
                                  matching: .images)
            .alert($store.scope(state: \.alert, action: \.alert))
        
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
            stickerOverlay.clipped()
        }
        .clipShape(.rect(cornerRadius: 30))
    }
    func gridItem(for index: Int) -> some View {
        Group {
            if let photos = store.photoGridState.photos[index]{
                let showTrashButton = index == store.photoGridState.selectedIndex && editMode
                PolaroidView(imageView: photos.image , showTrashButton: showTrashButton)
                    .frame(width: 126, height: 145)
                    .onTapGesture {
                        if editMode {
                            store.send(showTrashButton ? .showDeleteAlert : .photoGridAction(.clickEditImage(index)))
                        } else {
                            store.send(.photoGridAction(.clickFullScreenImage(index)))
                        }
                    }
            } else {
                EmptyPhotoView()
                    .frame(width: 126, height: 145)
                    .onTapGesture {
                        store.send(.photoGridAction(.addPhotoTapped(index: index)))
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
                    store.send(.showStickerPicker)
                }
            }
            FloatingButton(symbolName: editMode ? "checkmark" : nil, imageName: editMode ? nil : "PencilSimple", isEditButton: true) {
                editMode.toggle()
            }
        }
        .padding()
    }
    var stickerOverlay: some View {
        ForEach($store.stickersState.stickers) { sticker in
            ResizableRotatableStickerView(sticker: sticker) {
                store.send(.stickersAction(.removeSticker(id: sticker.id)))
            }
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        store.send(.stickersAction(.moveSticker(id: sticker.id, to: value.location)))
                    }))
        }
    }
}

#Preview {
    MemoriesView(store: Store(initialState: MemoryFeature.State()) {
        MemoryFeature()
    })
}
