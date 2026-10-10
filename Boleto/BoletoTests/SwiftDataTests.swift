//
//  DBSaveTests.swift
//  BoletoTests
//
//  Created by Sunho on 1/28/25.
//

import Foundation
import Testing
import ComposableArchitecture
import SwiftData

@testable import Boleto

@MainActor
struct SwiftDataTests {
    @Test("Success Save Badge")
    func successSaveBadge() async {
        let badgeType = StickerCodes.sl01
        let dummyData = StickerData(     stickerType: "STICKER",
                                         name: "경복궁",
                                         url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/SL01.png",
                                         isCollected: false,
                                         stickerCode: "SL01")
        let store = TestStore(initialState: BadgeNotificationFeature.State(badgeType: badgeType, stickerData: dummyData )) {
            BadgeNotificationFeature()
        } withDependencies: {
            $0.databaseClient = .testValue
            $0.stickerDatabase.collectSticker = { sticker in
           
            }
        }
        await store.send(.saveBadgeInSwiftData)
    }
}
