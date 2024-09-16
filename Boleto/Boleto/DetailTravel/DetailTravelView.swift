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
                    Spacer()
                    NumsParticipantsView(personNum: 3)
                }
                .padding(.top, 20)
                .padding(.horizontal,32)
                .padding(.bottom,10)
                ZStack {
                    if store.currentTab == 0{
                        TicketView(ticket: store.ticket)
                            .padding(.horizontal,16)
                        
                        
                    }else {
                        MemoriesView(store: store.scope(state: \.memoryFeature, action: \.memoryFeature))
                            .padding(.horizontal, 16)
                    }
                }
                //                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.easeInOut, value: currentTab)
            Spacer()
                
            }
            if let fullscreenImage =  store.memoryFeature.photoGridState.selectedFullScreenImage {
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
                    PolaroaidFullView(imageView: fullscreenImage)
                        .frame(width: 310, height: 356)
                        .transition(.scale)
                    Spacer()
                }
            }
        }
        .applyBackground(color: .background)
    }
    
}


#Preview {
    NavigationStack {
        DetailTravelView(store: Store(initialState: DetailTravelFeature.State(ticket: Ticket.dummyTicket)){
            DetailTravelFeature()
        })
        
    }
}



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
//                Spacer()
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
