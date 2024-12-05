//
//  MemoryView.swift
//  Boleto
//
//  Created by Sunho on 8/12/24.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture
import Kingfisher
struct MemoriesView: View {
    @Bindable var store: StoreOf<MemoryFeature>
    var columns: [GridItem] = [GridItem(.flexible(),spacing:  16), GridItem(.flexible())]
    var rotations: [Double] = [-4.5, 4.5, 4.5, -4.5, -4.5, 4.5, -4.5, 4.5, -4.5, 4.5]
    var body: some View {
        ZStack (alignment: .bottomTrailing){
            gridContent
            editButtons
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .confirmationDialog($store.scope(state: \.photoGridState.confirmationDialog, action: \.photoGridAction.confirmationDialog))
            .fullScreenCover(item: $store.scope(state: \.destination?.fourCutPicker, action: \.destination.fourCutPicker)) { store in
                AddFourCutView(store: store).applyBackground(color: .background)
            }
            .sheet(item: $store.scope(state: \.destination?.stickerPicker, action: \.destination.stickerPicker), content: { store in
                StickerPickerView(store: store)
                    .presentationDetents([.medium,.fraction(0.9)])
                
            })
            .photosPicker(isPresented: Binding(get: {store.destination == .photoPicker}, set: {_ in store.destination = nil}),
                          selection:  $store.selectedPhoto.sending(\.updateSelectedPhotos),
                          maxSelectionCount: 1,
                          matching: .images)
            .alert($store.scope(state: \.alert, action: \.alert))
            .task {
                store.send(.fetchMemory)
            }
            .onDisappear {
                if store.editMode {
                    store.send(.changeEditMode)
                }
            }
        
    }
    var gridContent: some View {
        ZStack {
            LazyVGrid(columns: columns, spacing: 32) {
                ForEach(Array(store.photoGridState.photos.enumerated()), id: \.offset) { rowIndex, row in
                    ForEach(0..<6, id: \.self) { colIndex in
                        gridItem(for: GridIndex(rowIndex * 6 + colIndex))
                    }
                }
            }
            .padding(.horizontal, 24)
            stickerOverlay.clipped()
        }
        .frame(maxHeight: .infinity)
        .background(store.color.color)
        .clipShape(.rect(cornerRadius: 30))
    }
    func gridItem(for index: GridIndex) -> some View {
        Group {
            if let photos = store.photoGridState.photos[index.row][index.col]{
                let showTrashButton = index == store.photoGridState.selectedIndex && store.editMode
                switch photos {
                case .singlePhoto(let singlePhoto):
                    trashViewWithOverlay(
                        content: PolaroidView(imageURL: singlePhoto.imageURL),
                        showTrashButton: showTrashButton,
                        index: index
                    )
                case .fourCut(let fourCutPhoto):
                    trashViewWithOverlay(
                        content:  FourCutView(data: fourCutPhoto, isSmallMode: false),
                        showTrashButton: showTrashButton,
                        index: index
                    )
                }
            } else {
                makeEmptyPhotoView()
                    .onTapGesture {
                        store.send(.photoGridAction(.addPhotoTapped(index)))
                    }
            }
        }.rotationEffect(Angle(degrees: rotations[index.linearIndex % rotations.count]))
    }
    func trashViewWithOverlay<T: View>(content: T, showTrashButton: Bool, index: GridIndex) -> some View {
        content
            .frame(width: 126, height: 145)
            .overlay {
                trashOverlayView(showTrashButton: showTrashButton)
            }
            .onTapGesture {
                store.send(
                    store.editMode
                    ? (showTrashButton ? .showDeleteAlert : .photoGridAction(.clickEditImage(index)))
                    : .photoGridAction(.clickFullScreenImage(index))
                )
            }
    }
    func makeEmptyPhotoView() -> some View {
        Image(systemName: "plus")
            .foregroundStyle(.gray1)
            .frame(width: 126  , height: 145)
            .background{
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray1, style: StrokeStyle(lineWidth: 1, dash: [10]))
            }
    }
    func trashOverlayView(showTrashButton: Bool) -> some View {
        ZStack {
            if showTrashButton {
                Color.black.opacity(0.6)
                Image(systemName: "trash")
                    .foregroundStyle(.white)
                    .font(.system(size: 24))
                    .background(Circle().frame(width: 32, height: 32).foregroundStyle(Color.black))
            }
        }
    }
    var editButtons: some View {
        VStack {
            FloatingButton(symbolName: nil, imageName: store.editMode ? "Sticker" : nil,isEditButton: false) {
                store.send(.showStickerPicker)
            }
            FloatingButton(symbolName: store.editMode ? nil : "square.and.arrow.up", imageName: store.editMode ? "ChatsCircle" : nil, isEditButton: false) {
                if store.editMode {
                    store.send(.stickersAction(.addSpeech))
                } else {
                    Task {
                        await captureView(of: gridContent) { image in
                            store.send(.captureGridContent(image))
                        }
                    }
                }
            }
            FloatingButton(symbolName: store.editMode ? "checkmark" : nil, imageName: store.editMode ? nil : "PencilSimple", isEditButton: true) {
                store.send(.changeEditMode)
            }
        }.offset(x: 16, y: 14)
    }
    var stickerOverlay: some View {
        ZStack {
            ForEach($store.stickersState.stickers) { sticker in
                ResizableRotatableStickerView(sticker: sticker, editMode: store.state.editMode, eraseTap: {
                    store.send(.stickersAction(.removeSticker(id: sticker.id)))
                }, onMove: {location in
                    store.send(.stickersAction(.moveSticker(id: sticker.id, to: location)))
                }, onSelect: {
                    store.send(.stickersAction(.selectSticker(id: sticker.id)))
                })
            }
            ForEach($store.stickersState.speechs) { sticker in
                ResizableRotatableStickerView(sticker: sticker, editMode: store.state.editMode, eraseTap: {
                    store.send(.stickersAction(.removeSticker(id: sticker.id)))
                }, onMove: {location in
                    store.send(.stickersAction(.moveSticker(id: sticker.id, to: location)))
                }, onSelect: {
                    store.send(.stickersAction(.selectSticker(id: sticker.id)))
                })
            }
        }
    }
}

#Preview {
    MemoriesView(store: Store(initialState: MemoryFeature.State(travelId: 19, ticketColor: .green)) {
        MemoryFeature()
    })
}

