//
//  MainTravelView.swift
//  Boleto
//
//  Created by Sunho on 8/11/24.
//

import SwiftUI
import ComposableArchitecture

struct DetailTravelView: View {
    @Bindable var store: StoreOf<DetailTravelFeature>
    @Namespace var namespace
    @State private var captureFrame: CGRect?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            VStack {
                HStack {
                    typeTabBarView
                    Spacer()
                    NumsParticipantsView(personNum: store.ticket.participant.count, isLocked: store.editStatus == .lockedByOthers)
                }
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                ZStack {
                    if store.currentTab == .ticket {
                        TicketView(
                            showModal: $store.isShowingParticipantModal,
                            ticket: store.ticket,
                            tapNavigate: {
                                store.send(.navigateToEditView)
                            })
                        .opacity(store.currentTab == .ticket ? 1 : 0)
                    } else {
                        MemoriesView(store: store.scope(state: \.memoryFeature, action: \.memoryFeature))
                            .opacity(store.currentTab == .memory ? 1 : 0)
                    }
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                captureFrame = geometry.frame(in: .global)
                            }
                            .onChange(of: geometry.frame(in: .global)) { _, newFrame in
                                captureFrame = newFrame
                            }
                    }
                )
                .animation(.easeInOut(duration: 0.6), value: store.currentTab)
                
                Spacer()
            }.padding(.horizontal,32)
            
            if let fullscreenImage =  store.memoryFeature.photoGridState.selectedFullScreenItem {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                VStack(spacing: 10) {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            store.send(.memoryFeature(.photoGridAction(.dismissFullScreenImage)))
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 21, height: 21)
                                .foregroundStyle(Color.white)
                        }
                    }.padding(.trailing, 40)
                    switch fullscreenImage {
                    case .singlePhoto(let photoItem):
                        PolaroidView(imageURL: photoItem.imageURL)
                            .padding(.horizontal,40)
                            .frame(height: 356)
                            .transition(.scale)
                        
                    case .fourCut(let fourCutModel):
                        AsyncImageView(urlString: fourCutModel.frameUrl, targetSize: CGSize(width: 800, height: 800), imagetype: .fourCut(urls: fourCutModel
                            .picturesURL, isLargeMode: true))
//                        FourCutView(data: fourCutModel, isSmallMode: true)
                            .padding(.horizontal,40)
                            .frame(height: 356)
                            .transition(.scale)
                        
                    }
                    Spacer()
                }
            }
            
            if !store.isCapturing {
                FloatingButtons
                    .padding(.trailing, 16)
                    .padding(.bottom, 56)
            }
            
            if store.isShowingParticipantModal {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        store.isShowingParticipantModal = false
                    }
                personModal
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 42)
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .applyBackground(color: .background)
        .onAppear{
            store.send(.fetchSingleTravel)
        }
    }
    private var FloatingButtons: some View {
        ZStack {
            if store.currentTab == .ticket {
                VStack(spacing: 10) {
                    FloatingButton(symbolName:  nil, imageName: "instagramIcon", isEditButton: false) {
                        Task {
                            store.isCapturing = true
                            try? await Task.sleep(nanoseconds: 100_000_000)
                            let capturedImage = try await self.captureSpecificArea(frame: captureFrame!)
                            store.send(.shareToInstagramStory(capturedImage))
                        }
                    }
                    FloatingButton(symbolName: nil, imageName: "PencilSimple", isEditButton: true) {
                        store.send(.navigateToEditView)
                    }
                }
            } else {
                VStack(spacing: 10) {
                    FloatingButton(symbolName: nil, imageName: store.memoryFeature.editStatus == .lockedByMe ? "Sticker" : nil, isEditButton: false) {
                        store.send(.memoryFeature(.showStickerPicker))
                    }
                    FloatingButton(symbolName: nil, imageName: store.memoryFeature.editStatus == .lockedByMe ? "ChatsCircle" : "instagramIcon", isEditButton: false) {
                        if store.memoryFeature.editStatus == .lockedByMe {
                            store.send(.memoryFeature(.stickersAction(.addSpeech)))
                        } else {
                            Task {
                                store.isCapturing = true
                                try? await Task.sleep(nanoseconds: 100_000_000)
                                let capturedImage = try await self.captureSpecificArea(frame: captureFrame!)
                                store.send(.shareToInstagramStory(capturedImage))
                            }
                        }
                    }
                    FloatingButton(symbolName: store.memoryFeature.editStatus == .lockedByMe ? "checkmark" : nil, imageName: store.memoryFeature.editStatus == .lockedByMe ? nil : "PencilSimple", isEditButton: true) {
                        store.send(.memoryFeature(.onTapEditMode))
                    }
                }
            }
            
        }
    }
    var typeTabBarView: some View {
        HStack(spacing: 22) {
            ForEach(TicketTab.allCases, id: \.self) { tab in
                Button {
                    store.send(.updateCurrentTab(tab))
                } label: {
                    VStack(spacing: 4) {
                        if store.currentTab == tab {
                            Text(tab.title)
                                .foregroundStyle(Color.mainColor)
                            Color.mainColor
                                .frame(width: 27, height: 2)
                                .matchedGeometryEffect(id: "underline", in: namespace)
                        } else {
                            Text(tab.title)
                                .foregroundStyle(Color.gray)
                            Color.clear
                                .frame(width: 27, height: 2)
                        }
                    }
                    .animation(.spring(), value: store.currentTab) // 애니메이션 추가
                }
                .buttonStyle(.plain) // 버튼 스타일 기본값
            }
        }
    }
    var personModal: some View {
        let ticket = store.ticket
        return VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: {
                    store.isShowingParticipantModal = false
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 21, height: 21)
                        .foregroundStyle(.white)
                        .padding(7) // 버튼 클릭 영역
                }
            }
            VStack {
                Text("더보기")
                    .foregroundStyle(.white)
                    .customTextStyle(.body1)
                    .padding(.bottom, 20)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 25), count: 4),spacing: 20) {
                    ForEach(ticket.participant, id: \.id) { person in
                        VStack(spacing: 5) {
                            if let url = person.imageUrl {
                                AsyncImageView(urlString: url, targetSize: CGSize(width: 42, height: 42), imagetype: .image)
                                    .frame(width:42,height:42)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: 2)
                                    )
                            } else {
                                Image("defaultprofile")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 42, height: 42)  .overlay(
                                        Circle().stroke(Color.white, lineWidth: 2)
                                    )
                            }
                            Text(person.name)
                                .foregroundColor(.white)
                                .customTextStyle(.small)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 10, leading: 28, bottom: 25, trailing: 28))
            .background(Color.modal)
            .cornerRadius(20)
        }
    }
    
}



//
//#Preview {
//    NavigationStack {
//        DetailTravelView(store: Store(initialState: DetailTravelFeature.State(ticket: Ticket.mockTickets[0], editStatus: .unlocked)){
//            DetailTravelFeature()
//        })
//
//    }
//}

