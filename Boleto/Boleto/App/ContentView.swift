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
                    .onAppear {
                        store.send(.requestLocationAuthorizaiton)
                    }
                    .task {
                        if store.viewstate == .loggedIn {
                            store.send(.allTicket(.fetchTickets))
                        }
                    }
                    .alert($store.scope(state: \.alert, action: \.alert))
                
            }destination: {store in
                switch store.case {
                case let .detailEditView(store):
                    DetailTravelView(store: store)
                        .navigationBarBackButtonHidden()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            CommonToolbar(store: self.store, title: "나의 여행")
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    self.store.send(.popAll)
                                } label: {
                                    Image(systemName: "chevron.backward")
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                case let .alarmsView( store):
                    AlarmsView(store: store)
                        .toolbarBackground(Color.background, for: .navigationBar)
                    
                case let .addticket(store):
                    AddTicketView(store: store)
                    
                    
                case let .myPage(store):
                    MyPageView(store: store)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(Color.background, for: .navigationBar)
                case let .editProfile(store):
                    EditProfileView(store: store)
                case let .myPhotos(store):
                    MyFrameView()
                        .toolbarBackground(Color.background, for: .navigationBar)
                case let .mySticker(store):
                    MyStickerView(store: store)
                        .toolbarBackground(Color.background, for: .navigationBar)
                case let .friendLists(store):
                    FriendListView(store: store)
                        .toolbarBackground(Color.background, for: .navigationBar)
                case let .invitedTravel(store):
                    MyInvitedView(store: store)
                        .toolbarBackground(Color.background, for: .navigationBar)
//                        .toolbarBackground(Color.background, for: .navigationBar)
                case let .badgeNotificationView(store):
                    BadgeNotificationView(store: store)
                case let .frameNotificationView(store):
                    FrameNotificationView(store: store)
                case let .pushSettingView(store):
                    PushSettingView(store: store)
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

//
#Preview {
    ContentView(store: .init(initialState: AppFeature.State(), reducer: {
        AppFeature()
    }))
}
