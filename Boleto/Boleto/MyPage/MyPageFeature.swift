//
//  MyPageFeature.swift
//  Boleto
//
//  Created by Sunho on 9/11/24.
//

import Foundation
import ComposableArchitecture
import SwiftUI
@Reducer
struct MyPageFeature {
    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("AlertOn")) var alertOn: Bool = false
        @Shared(.appStorage("LocationOn")) var locationOn: Bool  = false
        var notiAlert: Bool = false
        var locationAlert: Bool = false
        init() {
            self.notiAlert = alertOn
            self.locationAlert = locationOn
        }
    }
    
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case profileTapped
        case travelPhotosTapped
        case stickersTapped
        case friendListTapped
        case invitedTravelsTapped
    }
    @Dependency(\.locationClient) var locationclient
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.notiAlert):
                state.alertOn = state.notiAlert
                return .run { [alertOn = state.notiAlert] send in
                    if alertOn {
                        try await self.locationclient.requestNotiAuthorization()
                    } else {
                        await self.locationclient.removeAllScheduledNotifications()
                    }
                }
            case .binding(\.locationAlert) :
                state.locationOn = state.locationAlert
                return .run {[locationOn = state.locationAlert] send in
                    if locationOn {
                        let _ = await self.locationclient.requestauthorzizationStatus()
                    } else {
                        
                    }
                }
            default:
                return .none
            }
            
            
        }
    }
}
