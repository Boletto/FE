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
    var fetchAllSystem: @Sendable (Bool) async throws -> Void
    var updateStickerDB: @Sendable ([StickerData]) async throws -> Void
    var collectSticker: @Sendable (StickerData) async throws -> Void
    var deleteAllStickers: @Sendable () async throws -> Void
}
extension StickerDatabase: DependencyKey {
    public static  var liveValue: StickerDatabase = Self(
        fetchAllSystem: { isEvent in
            @Dependency(\.databaseClient.context) var context
            let stickerContext = try context()
            let existingStickers = try stickerContext.fetch(FetchDescriptor<StickerData>())
            if existingStickers.isEmpty {
                try await fetchAndSaveStickers(isEvent: false)
            }
            if isEvent {
                try await fetchAndSaveStickers(isEvent:  true)
            }
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
        }
    )
    static private func fetchAndSaveStickers(isEvent: Bool) async throws {
        @Dependency(\.databaseClient.context) var context
        let stickerContext = try context()
        let task = API.session.request(SystemRouter.getAllStickers(isEvent: isEvent), interceptor: RequestTokenInterceptor())
            .validate()
            .serializingDecodable(GeneralResponse<[SystemStickerResponse]>.self)
        switch await task.result {
        case .success(let data):
            guard let stickers = data.data else{return}
            for systemSticker in stickers {
                if systemSticker.stickerType == "SPEECH", !isEvent {
                    UserDefaults.standard.set(systemSticker.stickerURL, forKey: "speechImageURL")
                } else {
                    let stickerData = StickerData(
                        stickerType: systemSticker.stickerType,
                        name: systemSticker.stickerName,
                        url: systemSticker.stickerURL,
                        isCollected: isEvent || systemSticker.defaultProvided,
                        stickerCode: systemSticker.stickerCode
                    )
                    stickerContext.insert(stickerData)
                }
            }
            try stickerContext.save()
            
        case .failure(let err):
            throw err
        }
    }
}
    
extension DependencyValues {
    var stickerDatabase: StickerDatabase {
        get { self[StickerDatabase.self] }
        set { self[StickerDatabase.self] = newValue }
    }

}
