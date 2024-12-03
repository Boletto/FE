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

    init() {
        let nativeAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
        KakaoSDK.initSDK(appKey:"2fc0e561c1940671aa6a38aa818d360f")
    }
    var body: some Scene {
        WindowGroup {
            switch delegate.store.viewstate {
            case .loggedIn:
                ContentView(store: delegate.store)
                    .tint(.black)
                    .onAppear {
                        delegate.app = self
                        delegate.store.send(.initializeApp)
                        if let pendingCode = delegate.store.pendingInviteCode {
                            // 로그인후 바로 초대링크를 봤을때!
                            delegate.store.send(.showFriendAlert(pendingCode))
                        }
                    }
                    .onOpenURL {url in
                        hanldleUniverisalLink(url)
                    }
                    .task {
                    }
            case .loggedOut:
                LoginView(store: delegate.store.scope(state: \.loginState, action: \.login))
                    .onOpenURL {url in
                        hanldleUniverisalLink(url)
                    }
                  
                
            case .setProfile:
                AddProfileView(store: delegate.store.scope(state: \.profileState, action: \.profile))
            case .tutorial:
                TutorialView {
                    delegate.store.send(.setViewState(.loggedIn))
                }
            }
        }
        .modelContainer(SwiftDataModelConfigurationProvider.shared.container)
   
    }
    func hanldleUniverisalLink(_ url: URL) {
        let code = url.lastPathComponent
        if delegate.store.viewstate == .loggedIn {
            delegate.store.send(.showFriendAlert(code))
        } else {
            delegate.store.send(.setPendingInviteCode(code))
        }
        
    }
    func checkSielntMonitoring(silentData: SilentPushModel) {
        if silentData.eventType == "TRAVEL_START" {
            delegate.store.send(.startMonitoring(SpotType.fromKoreanString(silentData.arriveArea) ?? .dummy))
        } else {
            delegate.store.send(.stopMonitoring(SpotType.fromKoreanString(silentData.arriveArea) ?? .dummy))
        }
    }
    func handlePushNotification(data: [String: Any]) async {
        guard let type = data["NotificationType"] as? String else { return }
        
        switch type {
        case "badge":
            if let stickerTypeString = data["StickerImage"] as? String,
               let stickerType = StickerCodes(rawValue: stickerTypeString) {
                       delegate.store.send(.sendToBadgeView(stickerType))
                   }
        case "fourCutframe":
            if let spotString = data["Spot"] as? String,
               let spotType = SpotType.fromUpperString(spotString) {
                delegate.store.send(.sendToFrameView(spotType))}

            break
        default:
            break
        }
    }

}
//enum PushNotificationTypes: String {
//    case badge(StickerImage)
//    case fourCutframe
//        case invitedTickets
//}
