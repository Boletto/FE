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
                let task = API.session.request(SystemRouter.getAllStickers(isEvent: false), interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<[SystemStickerResponse]>.self)
                switch await task.result {
                case .success(let data):
                    guard let stickers = data.data else{return}
                    for systemsticker in stickers {
                        if systemsticker.stickerType == "SPEECH" {
                            UserDefaults.standard.set(systemsticker.stickerURL, forKey: "speechImageURL")
                                
                        } else {
                            // 나머지 스티커를 데이터베이스에 저장
                            let stickerData = StickerData(
                                stickerType: systemsticker.stickerType,
                                name: systemsticker.stickerName,
                                url: systemsticker.stickerURL,
                                isCollected: systemsticker.defaultProvided,
                                stickerCode: systemsticker.stickerCode
                            )
                            stickerContext.insert(stickerData)
                        }
                    }
                    try stickerContext.save()
                case .failure(let err):
                    throw err
                }
            }
            if isEvent {
                let task = API.session.request(SystemRouter.getAllStickers(isEvent: true),interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<[SystemStickerResponse]>.self)
                switch await task.result {
                case .success(let data):
                    guard let stickers = data.data else{return}
                    for systemsticker in stickers {
                        let stickerData = StickerData(
                            stickerType: systemsticker.stickerType,
                            name: systemsticker.stickerName,
                            url: systemsticker.stickerURL,
                            isCollected: true,
                            stickerCode: systemsticker.stickerCode
                        )
                        stickerContext.insert(stickerData)
                    }
                    try stickerContext.save()

                case .failure(let err):
                    throw err
                }
                
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
}
extension DependencyValues {
    var stickerDatabase: StickerDatabase {
        get { self[StickerDatabase.self] }
        set { self[StickerDatabase.self] = newValue }
    }
}
