//
//  ContentView.swift
//  Boleto
//
//  Created by Sunho on 8/9/24.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    @State var model: TabModel = TabModel()
    
    var body: some View {
        TabView(selection: self.$model.selectedTab) {
            Group {
                NavigationStack {
                    PastTravelView(store: Store(initialState: PastTravelFeature.State(), reducer: {
                        PastTravelFeature()
                    }))
                    .applyBackground(color: .background)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("지난 여행")
                                .foregroundStyle(.white)
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            toolbarContent
                        }
                    }
                }
                .tabItem { Image(systemName: "bookmark.fill")}
                .tag(TabModel.Tab.pastTravel)
                
                NavigationStack {
                    MainTravelView(store: Store(initialState: MainTravelFeatrue.State()) {
                        MainTravelFeatrue()
                    })
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("나의 여행")
                                .foregroundStyle(.white)
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            toolbarContent
                        }
                    }
                }
                .tabItem {
                    Image(systemName: "airplane")
                }
                .tag(TabModel.Tab.mainTravel)
                Text("tabcontent 3 ").tabItem { Image(systemName: "person.fill")}.tag(TabModel.Tab.myPage)
            }
            .toolbarBackground(.black, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            
        }
        
    }
    var toolbarContent: some View {
            HStack {
                Button(action: {}, label: {
                    Image(systemName: "bell")
                        .foregroundStyle(.white)
                })
                Button(action: {}, label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.white)
                })
            }
        }
}

@Observable
class TabModel {
    var selectedTab: Tab
    enum Tab {
        case pastTravel
        case mainTravel
        case myPage
    }
    init(selectedTab: Tab = .mainTravel) {
        self.selectedTab = .mainTravel
    }
}
#Preview {
    ContentView()
}
