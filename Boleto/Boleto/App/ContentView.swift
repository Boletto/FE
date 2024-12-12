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
        ZStack {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                AllTicketsOverView(store: store.scope(state: \.allTicketState, action: \.allTicket))
                    .applyBackground(color: .background)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        CommonToolbar(store: store, title: nil)
                    }
                    .task {
                        if store.viewstate == .loggedIn {
                            store.send(.allTicket(.fetchTickets))
                        }
                    }
                    .alert($store.scope(state: \.alert, action: \.alert))
                
            } destination: {store in
                switch store.case {
                case let .detailEditView(store):
                    NavigationDestinationView(title: "나의 여행") {
                        DetailTravelView(store: store)
                    }
                case let .alarmsView( store):
                    NavigationDestinationView(title: "나의 알림") {
                        AlarmsView(store: store)
                    }
                    
                case let .addticket(store):
                    NavigationDestinationView(title: store.mode  == .add ? "여행 추가" : "여행 편집"){
                        AddTicketView(store: store)
                    }
                case let .myPage(store):
                    NavigationDestinationView(title: "마이페이지") {
                        MyPageView(store: store)
                    }
                case let .editProfile(store):
                    NavigationDestinationView(title: "프로필 편집") {
                        EditProfileView(store: store)
                    }
 
                case .myPhotos:
                    NavigationDestinationView(title: "나의 여행네컷 프레임") {
                        MyFrameView()
                    }
                case let .mySticker(store):
                    NavigationDestinationView(title: "나의 스티커") {
                        MyStickerView(store: store)
                    }
                  
                case let .friendLists(store):
                    NavigationDestinationView(title: "친구 목록") {
                        FriendListView(store: store)
                    }
                case let .invitedTravel(store):
                    NavigationDestinationView(title: "초대받은 여행") {
                        MyInvitedView(store: store)
                    }
                
                case let .badgeNotificationView(store):
                    NavigationDestinationView(title: nil) {
                        BadgeNotificationView(store: store)
                    }
                   
                case let .frameNotificationView(store):
                    NavigationDestinationView(title: nil) {
                        FrameNotificationView(store: store)
                    }
               
                case let .pushSettingView(store):
                    NavigationDestinationView(title: "푸쉬설정") {
                        PushSettingView(store: store)
                    }
                case .rewardView:
                    RewardView()
                   
                }
            }
            if let invitedName = store.invitedFriendName {
                ReceiveFriendView(name: invitedName, onAccpet: {
                    store.send(.acceptFriend)
                }, onDecline: {
                    store.send(.rejectFriend)
                })
            }
        }
    }
}
#Preview {
    ContentView(store: .init(initialState: AppFeature.State(), reducer: {
        AppFeature()
    }))
}
