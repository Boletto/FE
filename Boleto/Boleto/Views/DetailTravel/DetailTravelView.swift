//
//  MainTravelView.swift
//  Boleto
//
//  Created by Sunho on 8/11/24.
//

import SwiftUI
import ComposableArchitecture

struct DetailTravelView: View {
    @State var currentTab: Int = 0
    @Bindable var store: StoreOf<DetailTravelFeature>
    @Namespace var namespace
    var tabbarOptions: [String] = ["티켓", "추억"]
    var body: some View {
        ZStack{
            VStack {
                HStack {
                    typeTabBarView
                    Spacer()
                    NumsParticipantsView(personNum: store.ticket.participant.count, isLocked: $store.memoryFeature.isLocked)
                }
                .padding(.top, 20)
                .padding(.bottom,10)
                ZStack {
                    if store.currentTab == 0{
                        TicketView(showModal: $store.isShowingParticipantModal, ticket: store.ticket, tapNavigate: {
                            store.send(.touchEditView)
                        }).task {
                            store.send(.fetchTikcket)
                        }
                    }else {
                        MemoriesView(store: store.scope(state: \.memoryFeature, action: \.memoryFeature))
                    }
                }
                .animation(.easeInOut, value: currentTab)
            Spacer()
                
            }.padding(.horizontal,32)
            if let fullscreenImage =  store.memoryFeature.photoGridState.selectedFullScreenItem {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            store.send(.memoryFeature(.photoGridAction(.dismissFullScreenImage)))
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.white)
                        }
                    }.padding()
                    switch fullscreenImage {
                    case .singlePhoto(let photoItem):
                        if let imageURL = photoItem.imageURL {
                            PolaroidView(imageURL: imageURL)
                                .frame(width: 310, height: 356)
                                .transition(.scale)
                        }
                    case .fourCut(let fourCutModel):
                        FourCutView(data: fourCutModel)
                                                    .frame(width: 310, height: 356)
                                                    .transition(.scale)
                    }
                    Spacer()
                }
            }
            if store.isShowingParticipantModal {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        store.isShowingParticipantModal = false
                    }
                personModal
                    .padding(.horizontal, 42)
            }
            
        }
        .applyBackground(color: .background)
    }
    var typeTabBarView: some View {
        HStack{
            ForEach(Array(tabbarOptions.enumerated()), id: \.offset) {index, title in
                TravelTabbaritem(
                    currentTab: $store.currentTab,
                    namespace: namespace,
                    title: title,
                    tab: index
                )
            }
        }
    }
    var personModal: some View {
        let ticket = store.ticket
        return VStack {
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
                            Image("profile")
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 42, height: 42)  .overlay(
                                    Circle().stroke(Color.white, lineWidth: 2)
                                )
                        }
                        Text(person.name ?? "")
                            .foregroundColor(.white)
                            .font(.customFont(ticket.keywords[0].regularfont, size: 8))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 10, leading: 28, bottom: 25, trailing: 28))

        .background(Color.modal)
        .cornerRadius(20)
        .padding()
    }
}

//
//#Preview {
//    NavigationStack {
//        DetailTravelView(store: Store(initialState: DetailTravelFeature.State(ticket: Ticket.dummyTicket)){
//            DetailTravelFeature()
//        })
//        
//    }
//}



struct TravelTabbaritem: View {
    @Binding var currentTab: Int
    let namespace: Namespace.ID
    var title: String
    var tab: Int
    
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
