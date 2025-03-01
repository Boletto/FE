//
//  AuthFeature.swift
//  Boleto
//
//  Created by Sunho on 2/27/25.
//

import Foundation
import ComposableArchitecture
@Reducer
struct AuthFeature {
    @ObservableState
    struct State {
        @Shared(.appStorage("isLogin")) var isLogin: Bool = false
        var userID: Int?
    }
    
    enum Action {
        case loginSuccess
        case sessionExpired
        case initialLogin
        case fetchMyStickers
        case fetchMyFrames
        case fetchEventSticker
        case fetchEventFrame
        case putFCMToken
        case requestNotification
        case refreshStickerDB
    }
    
    @Dependency(\.userClient) var userClient
    @Dependency(\.stickerDatabase) var stickerDBClient
    @Dependency(\.frameDBClient) var frameDBClient
    @Dependency(\.systemClient) var systemClient
    @Dependency(\.notificationClient) var notificationClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loginSuccess:
                state.isLogin = true
                if let idString = KeyChainManager.shared.read(key: .userid), let id = Int(idString) {
                    state.userID = id
                }
                return .none
                
            case .sessionExpired:
                state.isLogin = false
                KeyChainManager.shared.delete(key: .accessToken)
                KeyChainManager.shared.delete(key: .refreshToken)
                KeyChainManager.shared.delete(key: .userid)
                return .none
                
            case .initialLogin:
                state.isLogin = true
                if let idString = KeyChainManager.shared.read(key: .userid), let id = Int(idString) {
                         state.userID = id
                     } else {
                         print("유저 ID를 가져올 수 없습니다.")
                     }
                return .merge(
                            .send(.putFCMToken),
                            .send(.requestNotification),
                            .concatenate(
                                .send(.refreshStickerDB),
                                .send(.fetchMyFrames),
                                 .send(.fetchEventSticker),
                                 .send(.fetchMyStickers),
                                 .send(.fetchEventFrame)
                            )
                    )
            case .refreshStickerDB:
                return .run {_ in
                    try await stickerDBClient.deleteAllStickers()
                    let stickers = try await systemClient.getAllSticker(false)
                    try await stickerDBClient.addInStickerDB(stickers)
                }
            case .requestNotification:
                return .run { _ in
                    try await notificationClient.requestAuthorication()

                }
            case .putFCMToken:
                if let fcmToken = KeyChainManager.shared.read(key: .deviceToken) {
                    return .run {_ in
                        try await userClient.putFCMToken(fcmToken)
                    }
                } else { return .none}
            case .fetchMyStickers:
                return .run { send in
                    let myStickerImages = try await userClient.getStickers()
                    try await stickerDBClient.updateStickerDB(myStickerImages)
                }
            case .fetchMyFrames:
                return .run {send in
                    do {
                        let myFrames = try await userClient.getUserFrames()
                        try await frameDBClient.updateFrame(myFrames)
                        print("HI")
                    } catch {
                        print(error)
                    }
                }
            case .fetchEventSticker:
                return .run {send in
                    let eventstickers = try await systemClient.getAllSticker(true)
                    try await stickerDBClient.addInStickerDB(eventstickers)
                    for sticker in eventstickers {
                        let alreadyExists = try await stickerDBClient.hasStickers(sticker)
                           if !alreadyExists {
                               try await userClient.postStickerCode(sticker.stickerCode)
                           }
                       }
                    
                }
            case .fetchEventFrame:
                return .run { send in
                    let frames = try await systemClient.getEventFrames()
                    for frame in frames {
                        let alreadyExists = try await frameDBClient.hasFrame(frame)
                        if !alreadyExists {
                            try await userClient.postFrameCode(frame.frameCode)
                            try await frameDBClient.updateFrame([frame])
                        }
                    }
                }

            }
        }
    }
}
