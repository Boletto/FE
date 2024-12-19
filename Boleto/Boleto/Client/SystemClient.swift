//
//  SystemClient.swift
//  Boleto
//
//  Created by Sunho on 12/19/24.
//

import Foundation
import Alamofire
import ComposableArchitecture
@DependencyClient
struct SystemClient {
    var getAllSticker: @Sendable (Bool) async throws -> [StickerData]
}
extension SystemClient: DependencyKey {
    public static var liveValue: SystemClient = Self(
        getAllSticker: { isEvent in
            let data = try await NetworkManager.request(endpoint: SystemRouter.getAllStickers(isEvent: isEvent), responseType: [SystemStickerResponse].self)
            var stickerDatas = [StickerData]()
            for sticker in data {
                if sticker.stickerType == "SPEECH", !isEvent {
                    UserDefaults.standard.set(sticker.stickerURL, forKey: "speechImageURL")
                } else {
                    let stickerData = StickerData(stickerType: sticker.stickerType, name: sticker.stickerName, url: sticker.stickerURL, isCollected: isEvent || sticker.defaultProvided, stickerCode: sticker.stickerCode)
                    stickerDatas.append(stickerData)
                }
            }
            return stickerDatas
        }
    )
}
extension DependencyValues {
    var systemClient: SystemClient {
        get { self[SystemClient.self] }
        set { self[SystemClient.self] = newValue }
    }
}
