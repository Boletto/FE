//
//  MainTravelView.swift
//  Boleto
//
//  Created by Sunho on 8/11/24.
//

import SwiftUI
import ComposableArchitecture

struct MainTravelView: View {
    @State var currentTab: Int = 0
    @Bindable var store: StoreOf<MainTravelFeatrue>
    @Namespace var namespace
    var tabbarOptions: [String] = ["티켓", "추억"]
    var body: some View {
        
           
                haveTicketView
            .padding(.top, 20)
            
            .applyBackground(color: .background)
    }
    @ViewBuilder
    var haveTicketView: some View {
        ZStack{
            VStack {
                GeometryReader { geo in
                HStack(alignment: .bottom) {
                    HStack(alignment: .top){
                        ForEach(Array(tabbarOptions.enumerated()), id: \.offset) {index, title in
                            TravelTabbaritem(
                                currentTab: $store.currentTab,
                                namespace: namespace,
                                title: title,
                                tab: index
                            )
                        }
                    }
                    .frame(width: 80, height: 40)
                    .padding(.leading,32)
                    Spacer()
              
                    NumsParticipantsView(personNum: 3)
                        .padding(.trailing, 32)
                        .onTapGesture {
                            
                        }
     
                }.padding(.bottom,10)
                }.frame(height: 38)
                ZStack {
                    if store.currentTab == 0{
                        TicketView(ticket: store.ticket)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 100)
                    }else {
                        MemoriesView(store: store.scope(state: \.memoryFeature, action: \.memoryFeature))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(.easeInOut, value: currentTab)
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
    }
}


//#Preview {
//    NavigationStack {
//        MainTravelView(store: Store(initialState: MainTravelFeatrue.State()){
//            MainTravelFeatrue()
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
                Spacer()
                if currentTab == tab {
                    Text(title)
                        .foregroundStyle(Color.mainColor)
                    Color.mainColor.frame(height: 2)
                        .matchedGeometryEffect(id: "underline", in: namespace.self)
                } else {
                    Text(title)
                        .foregroundStyle(Color.gray)
                    Color.clear.frame(height: 2)
                }
            }
            .animation(.spring(), value: currentTab)
        }.buttonStyle(.plain)
    }
}
