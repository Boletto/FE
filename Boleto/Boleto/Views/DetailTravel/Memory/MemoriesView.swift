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
    @Environment(\.scenePhase) private var scenePhase
    private let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    private let angle = [-4.5,4.5,4.5,-4.5,-4.5,4.5]
    
    var body: some View {
        gridContent
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .task { store.send(.external(.fetchMemory) )}
            .confirmationDialog($store.scope(state: \.photoGridState.confirmationDialog, action: \.photoGridAction.confirmationDialog))
            .fullScreenCover(item: $store.scope(state: \.destination?.fourCutPicker, action: \.destination.fourCutPicker)) { store in
                AddFourCutView(store: store).applyBackground(color: .background)
            }
            .photosPicker(isPresented: Binding(get: {store.destination == .photoPicker}, set: {_ in store.destination = nil}),
                          selection: Binding(
                            get: { store.selectedPhoto },
                            set: { newPhotos in
                                store.send(.user(.updateSelectedPhotos(newPhotos)))
                            }
                          ),
                          maxSelectionCount: 1,
                          matching: .images)
            .sheet(item: $store.scope(state: \.destination?.stickerPicker, action: \.destination.stickerPicker)) { store in
                StickerPickerView(store: store)
                    .presentationDetents([.medium, .fraction(0.9)])
            }
            .sheet(item: $store.scope(state: \.destination?.imageEditor, action: \.destination.imageEditor)) { store in
                ImageEditorView(store: store)
                    .background(Color.modal.ignoresSafeArea())
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .onChange(of: scenePhase) {old,new in
                switch new {
                case .background:
                    store.send(.external(.ttiRecord("Memory","background")))
                case .active:
                    store.send(.external(.ttiRecord("Memory","foreground")))
                    
                default:
                    print(new)
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
        .padding(.horizontal, 18)
        .frame(height: screenHeight < 700 ? screenHeight * 0.75  : screenHeight * 0.7)
        .frame(width: self.getScreenBounds().width * 0.83)
        .overlay(stickerOverlay.clipped())
        .background(
            AsyncImageView(urlString: store.ticketFullURL, imagetype: .image)
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
                        content: AsyncImageView(urlString: fourCutPhoto.frameUrl, imagetype: .fourCut(urls: fourCutPhoto.picturesURL, isLargeMode: false)),
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
        let size = CGSize(width: getScreenBounds().width * 0.3, height: getScreenBounds().width * 0.345)
        return ZStack {
            content
                .frame(width: size.width, height: size.height)
            
            if showTrashButton {
                Color.black.opacity(0.6)
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Image(systemName: "trash")
                    .foregroundStyle(.white)
                    .font(.system(size: 24))
                    .background(Circle().frame(width: 32, height: 32).foregroundStyle(Color.black))
            }
        }
        //        .frame(width: size.width, height: size.height)
        .onTapGesture {
            store.send(
                store.editStatus == .lockedByMe
                ? (showTrashButton ? .user(.showDeleteAlert) : .photoGridAction(.clickEditImage(index)))
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
