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
   
        }.confirmationDialog($store.scope(state: \.confirmationDialog, action: \.confirmationDialog))
            .fullScreenCover(item: $store.scope(state: \.destination?.fourCutFullScreen, action: \.destination.fourCutFullScreen)) { store in
                AddFourCutView(store: store).applyBackground()
            }
            .sheet(item: $store.scope(state: \.destination?.stickerHalf, action: \.destination.stickerHalf), content: { store in
                StickerView(store: store)
                    .presentationDetents([.medium])

            })
            .photosPicker(isPresented: Binding(get: {store.destination == .photoPicker}, set: {_ in}), selection: $store.selectedPhotos.sending(\.updateSelectedPhotos),
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
            if let image = store.selectedPhotosImages[index] {
                let showTrashButton = index == store.selectedIndex && editMode
                PolaroidView(imageView: image, showTrashButton: showTrashButton)
                    .frame(width: 126, height: 145)
                    .onTapGesture {
                        if editMode {
                            if showTrashButton {
                                store.send(.showdeleteAlert)
                            } else {
                                store.send(.clickEditImage(index))}
                        } else {
                            store.send(.clickFullScreenImage(index))
                        }
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
    var stickerOverlay: some View {
        ForEach($store.stickers) { sticker in
            ResizableRotatableStickerView(sticker: sticker)
                .gesture(DragGesture().onChanged({ value in
                    
                    store.send(.moveSticker(id: sticker.id, to: value.location))
                }))
        }

    }
    
}

#Preview {
    MemoriesView(store: Store(initialState: MemoryFeature.State()) {
        MemoryFeature()
    })
}
