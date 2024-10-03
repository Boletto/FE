//
//  BoletoApp.swift
//  Boleto
//
//  Created by Sunho on 8/9/24.
//

import SwiftUI
import SwiftData
import ComposableArchitecture
import CoreLocation
import KakaoSDKCommon
@main
struct BoletoApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    
//    @MainActor
//    static let store = Store(initialState: AppFeature.State()) {
//        AppFeature()
//            ._printChanges()
//    }
    init() {
        let nativeAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
        KakaoSDK.initSDK(appKey:"2fc0e561c1940671aa6a38aa818d360f")
    }
    var body: some Scene {
        WindowGroup {
            switch delegate.store.viewstate {
            case .loggedIn:
                ContentView(store: delegate.store)
                    .tint(.white)
                    .onAppear {
                        delegate.app = self
//                                    Self.store.isLogin = false
                        print("HEY WHY?")
                    }
                    .task {
                        await startMonitoring()
                    }
            case .loggedOut:
                LoginView(store: delegate.store.scope(state: \.loginState, action: \.login))
            case .setProfile:
                AddProfileView(store: delegate.store.scope(state: \.profileState, action: \.profile))
            case .tutorial:
                TutorialView {
                    delegate.store.send(.setViewState(.loggedIn))
                }
            }
        }.modelContainer(SwiftDataModelConfigurationProvider.shared.container)
    }

    func handlePushNotification(data: [String: Any]) async {
        guard let type = data["NotificationType"] as? String else {return}
        switch PushNotificationTypes(rawValue: type) {
        case .badge:
            delegate.store.send(.sendToBadgeView)
        case .fourCutframe:
            delegate.store.send(.sendToFrameView)
        case .invitedTickets:
            delegate.store.send(.tabNotification)
            
        default:
            break
            
        }
    }
    func startMonitoring() async {
        await delegate.store.send(.requestLocationAuthorizaiton)
        let testLocation = CLLocationCoordinate2D(latitude: 37.24809168536956, longitude: 127.0422557)
        let testSpot = Spot.seoul
        await delegate.store.send(.toggleMonitoring(testSpot))
    }
}
enum PushNotificationTypes: String {
    case badge
    case fourCutframe
        case invitedTickets
}
