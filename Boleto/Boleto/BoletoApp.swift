//
//  BoletoApp.swift
//  Boleto
//
//  Created by Sunho on 8/9/24.
//

import SwiftUI
import SwiftData
import ComposableArchitecture
@main
struct BoletoApp: App {
    @MainActor
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
    }
    var body: some Scene {
        WindowGroup {
            ContentView(store: Self.store)

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
                BadgeData(name: "남산", imageName: "seoulSticker2", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                BadgeData(name: "성산일출봉", imageName: "JejuBadge2", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                
                // 나머지 스티커 데이터 추가
            ]
            
            badges.forEach { context.insert($0) }
        do {
              try context.save()
          } catch {
              fatalError("Failed to save initial badges: \(error)")
          }
        
        }
}
