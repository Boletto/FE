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
                Text("Tab Content 1").tabItem { Image(systemName: "bookmark.fill")}.tag(TabModel.Tab.pastTravel)
                MainTravelView().tabItem { Image(systemName: "airplane") }.tag(TabModel.Tab.mainTravel)
                Text("tabcontent 3 ").tabItem { Image(systemName: "person.fill")}.tag(TabModel.Tab.myPage)
            }
            .toolbarBackground(.black, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            
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
