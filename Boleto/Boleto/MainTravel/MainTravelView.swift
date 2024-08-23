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
        ZStack{
            VStack {
                HStack {
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
                    Spacer()
                }.padding()
                VStack {
                    if store.currentTab == 0{
                        TicketsView()
                    }else {
                        MemoriesView(store: store.scope(state: \.memoryFeature, action: \.memoryFeature))
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(.easeInOut, value: currentTab)
            }
            if let fullscreenImage =  store.memoryFeature.selectedFullScreenImage {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            store.send(.memoryFeature(.dismissFullScreenImage))
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.white)
                        }
                    }.padding()
                    PolaroidView(imageView: fullscreenImage, isExpanded: true)
                        .frame(width: 310, height: 356)
                        .transition(.scale)
                    Spacer()
                }
            }
        }
        .applyBackground()
    }
}


#Preview {
    NavigationStack {
        MainTravelView(store: Store(initialState: MainTravelFeatrue.State()){
            MainTravelFeatrue()
        })}
}
struct TicketsView: View {
    var body: some View {
        // 티켓 탭에 대한 콘텐츠
        Text("티켓 내용 표시")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(10)
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
            VStack {
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
