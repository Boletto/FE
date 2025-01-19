//
//  StickerDatabase.swift
//  Boleto
//
//  Created by Sunho on 11/26/24.
//

import Foundation
import ComposableArchitecture
import SwiftData

struct StickerDatabase {
    var addInStickerDB: @Sendable ([StickerData]) async throws -> Void
    var updateStickerDB: @Sendable ([StickerData]) async throws -> Void
    var collectSticker: @Sendable (StickerData) async throws -> Void
    var deleteAllStickers: @Sendable () async throws -> Void
    var hasStickers: @Sendable (StickerData) async throws -> Bool
    var isEmpty: @Sendable () async throws -> Bool
}
extension StickerDatabase: DependencyKey {
    public static  var liveValue: StickerDatabase = Self(
        addInStickerDB: { stickers in
            @Dependency(\.databaseClient.context) var context
            let stickerContext = try context()
            let existingStickers = try stickerContext.fetch(FetchDescriptor<StickerData>())
            let existingStickerCodes = Set(existingStickers.map { $0.stickerCode })
            let newStickers = stickers.filter { !existingStickerCodes.contains($0.stickerCode) }
            
            for sticker in newStickers {
                  stickerContext.insert(sticker)
              }
            try stickerContext.save()

        }, updateStickerDB:  {stickers in
            @Dependency(\.databaseClient.context) var context
            let stickerContext = try context()
            let stickerCodes = stickers.map { $0.stickerCode }
            let descriptor = FetchDescriptor<StickerData>(
                predicate: #Predicate<StickerData> { dbSticker in
                    stickerCodes.contains(dbSticker.stickerCode)
                }
            )
            let matchingStickers = try stickerContext.fetch(descriptor)
            
            // 딕셔너리로 변환 (이름을 키로 사용)
            var stickerMap = Dictionary(uniqueKeysWithValues: matchingStickers.map { ($0.stickerCode, $0) })
            
            // 매칭된 스티커 업데이트
            for sticker in stickers {
                if let dbSticker = stickerMap[sticker.stickerCode] {
                    dbSticker.isCollected = true
                }
            }
            try stickerContext.save()
        },
        collectSticker: {sticker in
            @Dependency(\.databaseClient.context) var context
            let stickerContext = try context()
            let findCode = sticker.stickerCode
            let descritpor = FetchDescriptor<StickerData> (predicate: #Predicate<StickerData> {$0.stickerCode == findCode})
            let matchSticker = try stickerContext.fetch(descritpor).first!
            matchSticker.isCollected = true
            
            try stickerContext.save()
            
        }, deleteAllStickers: {
            @Dependency(\.databaseClient.context) var context
            let stickerContext = try context()
            let allStickers = try stickerContext.fetch(FetchDescriptor<StickerData>()) // 모든 스티커 가져오기
            for sticker in allStickers {
                stickerContext.delete(sticker) // 스티커 삭제
            }
            try stickerContext.save()
            }, hasStickers: {sticker in
                @Dependency(\.databaseClient.context) var context
                let stickerContext = try context()
                let findcode = sticker.stickerCode
                let predicate = #Predicate<StickerData> {
                    $0.stickerCode == findcode
                }

                let request = FetchDescriptor<StickerData>(predicate: predicate)
                let existing = try stickerContext.fetch(request)
                return !existing.isEmpty
            }, isEmpty: {
                @Dependency(\.databaseClient.context) var context
                let stickerContext = try context()
                let request = FetchDescriptor<StickerData>()
                  let isexist = try stickerContext.fetch(request)
                return isexist.isEmpty
            }
    )
}
    
extension DependencyValues {
    var stickerDatabase: StickerDatabase {
        get { self[StickerDatabase.self] }
        set { self[StickerDatabase.self] = newValue }
    }

}
