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
    
    @MainActor
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
    }
    init() {
        let nativeAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
        KakaoSDK.initSDK(appKey:"2fc0e561c1940671aa6a38aa818d360f")
    }
    var body: some Scene {
        WindowGroup {

            if Self.store.currentLogin {
                            ContentView(store: Self.store)
                                .tint(.white)
                                .onAppear {
                                    delegate.app = self
//                                    Self.store.isLogin = false
                                }
                                .task {
                                    await startMonitoring()
                                }
            } else {
                LoginView(store: Self.store.scope(state: \.loginState, action: \.login))
            }

        }.modelContainer(for: BadgeData.self, inMemory: false) {result in
            switch result {
            case .success(let container):
                if try! container.mainContext.fetch(FetchDescriptor<BadgeData>()).isEmpty {
                    loadInitialStickers(context: container.mainContext)
                }
            case .failure(let err):
                fatalError("\(err)")
            }
        }
    }
    func loadInitialStickers(context: ModelContext) {
            let badges = [
                BadgeData(name: "경복궁", imageName: "seoulSticker1", latitude: 37.5759, longtitude: 126.9768, isCollected: false),
                BadgeData(name: "남산타워", imageName: "seoulSticker2", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                BadgeData(name: "한라산 국립공원", imageName: "JejuBadge2", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                BadgeData(name: "주상절리대", imageName: "JejuBadge1", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                BadgeData(name: "카멜리아 힐", imageName: "JejuBadge3", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                BadgeData(name: "이호테우 해수욕장", imageName: "JejuBadge4", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                BadgeData(name: "BIFF 과장", imageName: "BusanBadge3", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                BadgeData(name: "광안대교", imageName: "BusanBadge1", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                BadgeData(name: "해운대 해수욕장", imageName: "BusanBadge2", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                BadgeData(name: "영화의 전당", imageName: "BusanBadge4", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                BadgeData(name: "석촌호수", imageName: "seoulSticker3", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                BadgeData(name: "낙산공원", imageName: "seoulSticker4", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                
                // 나머지 스티커 데이터 추가
            ]
            
            badges.forEach { context.insert($0) }
        do {
              try context.save()
          } catch {
              fatalError("Failed to save initial badges: \(error)")
          }
        
        }
    func handlePushNotification(data: [String: Any]) async {
        guard let type = data["NotificationType"] as? String else {return}
        switch PushNotificationTypes(rawValue: type) {
        case .badge:
            Self.store.send(.sendToBadgeView)
        case .fourCutframe:
            Self.store.send(.sendToFrameView)
        case .invitedTickets:
            Self.store.send(.tabNotification)
            
        default:
            break
            
        }
    }
    func startMonitoring() async {
        await Self.store.send(.requestLocationAuthorizaiton)
        let testLocation = CLLocationCoordinate2D(latitude: 37.24809168536956, longitude: 127.0422557)
        let testSpot = Spot.seoul
        await Self.store.send(.toggleMonitoring(testSpot))
    }
}
enum PushNotificationTypes: String {
    case badge
    case fourCutframe
        case invitedTickets
}
