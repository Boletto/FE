//
//  ContentView.swift
//  Boleto
//
//  Created by Sunho on 8/9/24.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            Group {
                NavigationStack( path:
                    $store.scope(state: \.pastTravel.path, action: \.pastTravel.path)
                ){
                    PastTravelView(store: self.store.scope(state: \.pastTravel, action: \.pastTravel))
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
                    
                } destination: {store in
                    PastTicketDetailView(store: store)
                        .toolbar(.hidden, for: .tabBar)
                }
                .tabItem { Image(systemName: "bookmark.fill")}
                .tag(AppFeature.Tab.pastTravel)
                
                NavigationStack {
                    MainTravelView(store: self.store.scope(state: \.mainTravel, action: \.mainTravel))
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
                .tag(AppFeature.Tab.mainTravel)
                
                NavigationStack(path: $store.scope(state: \.myPage.path, action: \.myPage.path))
                {
                    MyPageView(store: self.store.scope(state: \.myPage, action: \.myPage))
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("마이페이지")
                                    .foregroundStyle(.white)
                            }
                            ToolbarItem(placement: .topBarTrailing) {
                                toolbarContent
                            }
                        }
                } destination : { store in
                    switch store.case {
                    case .profile(let store):
                        EditProfileView(store: store)
                    case .mySticker(let store):
                        MyStickerView(store: store)
                    case .invitedTravel(let store):
                        MyInvitedView(store: store)
                    default:
                        EmptyView()
                    }}
                .tabItem { Image(systemName: "person.fill")}
                .tag(AppFeature.Tab.myPage)
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

//
//#Preview {
//    ContentView()
//}
