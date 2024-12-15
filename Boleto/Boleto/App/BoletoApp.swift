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
    
    func checkSilentMonitoring(silentData: SilentPushModel) {
        switch silentData.eventType {
        case .fetchEventStickers:
            store.send(.fetchEventSticker)

        case .fetchEventFrames:
            store.send(.fetchEventFrame)

        case .startMonitoring(let spotType):
            store.send(.startMonitoring(spotType))

        case .stopMonitoring(let spotType):
            store.send(.stopMonitoring(spotType))
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
               let spotType = SpotType.fromKoreanString(spotString) {
                store.send(.sendToFrameView(spotType))}
            
        case "TRAVEL_TICKET":
            if let travelId = data["travelId"]  as? String{
                store.send(.sendToInvitedView(Int(travelId)!))
            }
        case "FRIEND_ACCEPT" :
            store.path.append(.friendLists(FriendsFeature.State()))
            
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
