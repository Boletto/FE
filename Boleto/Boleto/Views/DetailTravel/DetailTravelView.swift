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
    @State private var ticketViewSnapshot: UIImage? // 캡처된 이미지를 저장하는 상태 변수

    var tabbarOptions: [String] = ["티켓", "추억"]
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            VStack {
                HStack {
                    typeTabBarView
                    Spacer()
                    NumsParticipantsView(personNum: store.ticket.participant.count, isLocked: store.editStatus == .lockedByOthers)
                }
                .padding(.top, 20)
                Spacer().frame(height: 16)
                ZStack {
                    if store.currentTab == .ticket {
                        TicketView(
                            showModal: $store.isShowingParticipantModal,
                            ticket: store.ticket,
                            tapNavigate: {
                                store.send(.navigateToEditView)
                            })
                            .rotation3DEffect(
                                .degrees(store.currentTab == .ticket ? 0 : 180),
                                axis: (x: 0, y: 1, z: 0),
                                anchor: .center,
                                perspective: 0.5
                            )
                            .opacity(store.currentTab == .ticket ? 1 : 0)
                    } else {
                        MemoriesView(store: store.scope(state: \.memoryFeature, action: \.memoryFeature))
                            .rotation3DEffect(
                                .degrees(store.currentTab == .memory ? 0 : -180),
                                axis: (x: 0, y: 1, z: 0),
                                anchor: .center,
                                perspective: 0.5
                            )
                            .opacity(store.currentTab == .memory ? 1 : 0)
                    }
                } .animation(.easeInOut(duration: 0.6), value: store.currentTab) // 애니메이션 유지
                
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
                        FourCutView(data: fourCutModel, isSmallMode: true)
                            .padding(.horizontal,40)
                            .frame(height: 356)
                            .transition(.scale)
                        
                    }
                    Spacer()
                }
            }
            
            FloatingButtons
                .padding(.trailing, 16)
                .padding(.bottom, 56)
            
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
        .applyBackground(color: .background)
        .onAppear{
            store.send(.fetchSingleTravel)
        }
    }
    private var FloatingButtons: some View {
        Group {
            if store.currentTab == .ticket {
                VStack(spacing: 10) {
                    FloatingButton(symbolName:  nil, imageName: "instagramIcon", isEditButton: false) {
                        Task {
                            captureView(of: TicketView(
                                showModal: $store.isShowingParticipantModal,
                                ticket: store.ticket,
                                tapNavigate: {
                                    store.send(.navigateToEditView)
                                }).singleticketView) {
                                store.send(.shareToInstagramStory($0))
                            }
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
                                captureView(of: MemoriesView(store: store.scope(state: \.memoryFeature, action: \.memoryFeature)).gridContent) {
                                    store.send(.shareToInstagramStory($0))
                                }
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
        HStack(spacing: 22){
            ForEach(TicketTab.allCases, id: \.self) { tab in
                TravelTabbaritem(
                    currentTab: $store.currentTab,
                    namespace: namespace,
                    title: tab.title,
                    tab: tab
                )
            }}
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
                            URLImageView(urlstring: url,size: CGSize(width: 42, height: 42))
                                .clipShape(Circle())
                                .frame(width: 42, height: 42)  .overlay(
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



struct TravelTabbaritem: View {
    @Binding var currentTab: TicketTab
    let namespace: Namespace.ID
    var title: String
    var tab: TicketTab
    
    var body: some View {
        Button {
            currentTab = tab
        } label: {
            VStack(spacing: 4) {
                if currentTab == tab {
                    Text(title)
                        .foregroundStyle(Color.mainColor)
                    Color.mainColor.frame(width: 27,height: 2)
                        .matchedGeometryEffect(id: "underline", in: namespace.self)
                } else {
                    Text(title)
                        .foregroundStyle(Color.gray)
                    Color.clear.frame(width: 27,height: 2)
                }
            }
            .animation(.spring(), value: currentTab)
        }.buttonStyle(.plain)
    }
    
}

#Preview {
    NavigationStack {
        DetailTravelView(store: Store(initialState: DetailTravelFeature.State(ticket: Ticket.mockTickets[0], editStatus: .unlocked)){
            DetailTravelFeature()
        })

    }
}

