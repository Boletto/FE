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
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    init() {
        guard let nativeAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else {fatalError("API_KEY not found in Info.plist")}
        KakaoSDK.initSDK(appKey: nativeAppKey)
    }
    var body: some Scene {
        WindowGroup {
            
            switch store.viewstate {
            case .splash:
                LottieView(fileName: "splash", onEnd: {
                    store.send( store.isLogin ? .setViewState(.loggedIn) : .setViewState(.loggedOut))
                }).ignoresSafeArea(.all)
            case .agreement:
                TermsAgreementView() {
                    store.send(.setViewState(.setProfile))
                }
            case .loggedIn:
                ContentView(store: store)
                    .tint(.black)
                    .onAppear {
                        delegate.app = self
                        if let pendingCode = store.pendingInviteCode {
                            store.send(.showFriendAlert(pendingCode))
                        }
                    }
                    .onOpenURL {url in
                        hanldleUniverisalLink(url)
                    }
            case .loggedOut:
                LoginView(store: store.scope(state: \.loginState, action: \.login))
                    .onOpenURL {url in
                        hanldleUniverisalLink(url)
                    }
                
                
            case .setProfile:
                EditProfileView(store: store.scope(state: \.profileState, action: \.profile))
                    .applyBackground(color: .background)
            case .tutorial:
                TutorialView {
                    store.send(.initialLogin)
                }
                
                
            }
        }
        .modelContainer(SwiftDataModelConfigurationProvider.shared.container)
        
    }
    func hanldleUniverisalLink(_ url: URL) {
        let code = url.lastPathComponent
        if store.viewstate == .loggedIn {
            store.send(.showFriendAlert(code))
        } else {
            store.send(.setPendingInviteCode(code))
        }
        
    }
    func checkSielntMonitoring(silentData: SilentPushModel) {
        if silentData.eventType == "TRAVEL_START" {
            store.send(.startMonitoring(SpotType.fromKoreanString(silentData.arriveArea) ?? .seoul))
        } else {
            store.send(.stopMonitoring(SpotType.fromKoreanString(silentData.arriveArea) ?? .busan))
        }
    }
    func handlePushNotification(data: [String: Any]) async {
        guard let type = data["eventType"] as? String else { return }
        
        switch type {
        case "badge":
            if let stickerTypeString = data["StickerImage"] as? String,
               let stickerType = StickerCodes(rawValue: stickerTypeString) {
                store.send(.sendToBadgeView(stickerType))
            }
        case "fourCutframe":
            if let spotString = data["Spot"] as? String,
               let spotType = SpotType.fromUpperString(spotString) {
                store.send(.sendToFrameView(spotType))}
            
        case "TRAVEL_INVITE":
            if let travelId = data["travelId"]  as? String{
                store.send(.sendToInvitedView(Int(travelId)!))
            }
            
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
