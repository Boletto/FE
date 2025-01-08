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
    private let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    private let angle = [-4.5,4.5,4.5,-4.5,-4.5,4.5]
    
    var body: some View {
        
        gridContent
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .task { store.send(.fetchMemory) }
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
            .sheet(isPresented: Binding(
                get: {store.selectedUiimage != nil},
                set: {_ in store.selectedUiimage == nil}
            )) {
                if let image = store.selectedUiimage {
                    ImageEditorView(image: image) { cropimage in
                        store.send(.imageEditorComplete(cropimage))}
                    .background(Color.modal.ignoresSafeArea())
                }
            }
    }
    
    var gridContent: some View {
        let screenHeight = getScreenBounds().height
        return LazyVGrid(columns: columns, spacing: 32) {
            ForEach(Array(store.photoGridState.photos.enumerated()), id: \.offset) { rowIndex, row in
                ForEach(0..<6, id: \.self) { colIndex in
                    gridItem(for: GridIndex(rowIndex * 6 + colIndex))
                }
            }
        }
//        .padding(.vertical, 48)
        .padding(.horizontal, 18)
        .frame(height: screenHeight < 700 ? screenHeight * 0.75  : screenHeight * 0.7)
        .frame(width: self.getScreenBounds().width * 0.83)
        .overlay(stickerOverlay.clipped())
        .background(KFImage.url(store.ticketFullURL)
            .resizable()
            .scaledToFill()
        ).onAppear {
            print("height\(screenHeight)")
        }
        
    }
    
    func gridItem(for index: GridIndex) -> some View {
        Group {
            if let photos = store.photoGridState.photos[index.row][index.col]{
                let showTrashButton = index == store.photoGridState.selectedIndex && store.editStatus == .lockedByMe
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
        }
      
        .rotationEffect(
            Angle(degrees: angle[(index.row * 6 + index.col) % angle.count])
        )
    }
    
    func trashViewWithOverlay<T: View>(content: T, showTrashButton: Bool, index: GridIndex) -> some View {
        content
            .frame(width: getScreenBounds().width * 0.3, height: getScreenBounds().width * 0.345 )
            .overlay {
                trashOverlayView(showTrashButton: showTrashButton)
                    .clipShape(.rect(cornerRadius: 10))
            }
            .onTapGesture {
                store.send(
                    store.editStatus == .lockedByMe
                    ? (showTrashButton ? .showDeleteAlert : .photoGridAction(.clickEditImage(index)))
                    : .photoGridAction(.clickFullScreenImage(index))
                )
            }
    }
    func makeEmptyPhotoView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10) // 코너 반경을 너비 기반으로 설정
                .stroke(.gray1, style: StrokeStyle(lineWidth: 1, dash: [10]))
            
            Image(systemName: "plus")
                .foregroundStyle(.gray1)
                .font(.system(size: getScreenBounds().width * 0.05)) // 폰트 크기를 너비 기반으로 설정
        }  .frame(width: getScreenBounds().width * 0.3, height: getScreenBounds().width * 0.345 )
     
        
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
    
    var stickerOverlay: some View {
        ZStack {
            ForEach($store.stickersState.stickers) { sticker in
                ResizableRotatableStickerView(sticker: sticker, editMode: store.state.editStatus == .lockedByMe, eraseTap: {
                    store.send(.stickersAction(.removeSticker(id: sticker.id)))
                }, onMove: {location in
                    store.send(.stickersAction(.moveSticker(id: sticker.id, to: location)))
                }, onSelect: {
                    store.send(.stickersAction(.selectSticker(id: sticker.id)))
                })
            }
            ForEach($store.stickersState.speechs) { sticker in
                ResizableRotatableStickerView(sticker: sticker, editMode: store.state.editStatus == .lockedByMe, eraseTap: {
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
////
//#Preview {
//    MemoriesView(store: Store(initialState: MemoryFeature.State(travelId: 19, )) {
//        MemoryFeature()
//    })
//}
//
