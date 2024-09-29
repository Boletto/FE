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
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
//            Group {
//                switch store.viewstate {
//                case .determining:
//                    ProgressView()
//                case .loggedIn:
                    MainTravelTicketsView(store: store.scope(state: \.pastTravel, action: \.pastTravel))
                        .applyBackground(color: .background)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            CommonToolbar(store: store, title: nil)
                        }
                        .onAppear {
                            store.send(.requestLocationAuthorizaiton)
                            store.send(.toggleNoti(true))
                            store.send(.toggleMonitoring(.seoul))
                            print("Onapeear")
                        }
                        .task {
                            guard store.currentLogin else {return }
                            store.send(.pastTravel(.fetchTickets))
                        }
//                case .loggedOut:
//                    LoginView(store: store.scope(state: \.loginState, action: \.login))
//                }
//            }
//            Group {
//                if store.currentLogin {
//                    MainTravelTicketsView(store: store.scope(state: \.pastTravel, action: \.pastTravel))
//                        .applyBackground(color: .background)
//                        .navigationBarTitleDisplayMode(.inline)
//                        .toolbar {
//                            CommonToolbar(store: store, title: nil)
//                        }
//                        .onAppear {
//                            store.send(.requestLocationAuthorizaiton)
//                            store.send(.toggleNoti(true))
//                            store.send(.toggleMonitoring(.seoul))
//                            print("Onapeear")
//                        }
//                } else {
//                    LoginView(store: store.scope(state: \.loginState, action: \.login))
//                }
//            }
        } destination: {store in
            switch store.case {
            case let .detailEditView(store):
                DetailTravelView(store: store)
                    .navigationBarBackButtonHidden()
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
            case let .notifications( store):
                NotificationView(store: store)
                
            case let .addticket(store):
                AddTicketView(store: store)
                
            case let .myPage(store):
                MyPageView(store: store)
                
            case let .editProfile(store):
                EditProfileView(store: store)
            case let .myPhotos(store):
                EmptyView()
            case let .mySticker(store):
                MyStickerView(store: store)
            case let .friendLists(store):
                EmptyView()
            case let .invitedTravel(store):
                MyInvitedView(store: store)
            case let .badgeNotificationView(store):
                EmptyView()
            case let .frameNotificationView(store):
                FrameNotificationView(store: store)
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
