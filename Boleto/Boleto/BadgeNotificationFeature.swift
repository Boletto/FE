//
//  BadgeNotificationFeature.swift
//  Boleto
//
//  Created by Sunho on 9/19/24.
//

import ComposableArchitecture
import SwiftData
import SwiftUI
import Photos
import Kingfisher
@Reducer
struct BadgeNotificationFeature {
    @Dependency(\.dismiss) var dimisss
    
    @ObservableState
    struct State: Equatable {
        let badgeType: StickerCodes
        var showAlert = false
        var stickerData: StickerData?
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action: Equatable {
        case alert(PresentationAction<Alert>)
        case tapsaveBadgeGallery
        case saveLocalIsSuccess(Bool)
        case saveBadgeInSwiftData
        case tapCheck
        case fetchBadgeFromDB
        case updateUI(StickerData)
        enum Alert:Equatable {
            
        }
    }
    @Dependency(\.databaseClient.context) var context
    @Dependency(\.photoLibrary) var photoLibaryClient
    @Dependency(\.stickerDatabase) var stickerClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchBadgeFromDB:
                return .run {[stickerCode = state.badgeType.rawValue] send in
                    do {
                        let stickerContext = try context()
                        let stickerData = try stickerContext.fetch(
                            FetchDescriptor<StickerData>(
                                predicate: #Predicate<StickerData> { $0.stickerCode == stickerCode }
                            )
                        ).first
                        
                        if let stickerData = stickerData {
                            await send(.updateUI(stickerData))
                        }
                    } catch {
                        print("Failed to fetch sticker data: \(error)")
                    }
                }
            case .updateUI(let data):
                state.stickerData = data
                return .send(.saveBadgeInSwiftData)
            case .tapCheck:
                return .run {send in
                    await dimisss()
                }
            case .saveBadgeInSwiftData:
                guard let stickerImage = state.stickerData else {return .none}
                return .run { send in
                    do {
                        try await stickerClient.collectSticker(stickerImage)
                    } catch {
                        throw error
                    }
                }
            case .alert:
                return .none
            case .tapsaveBadgeGallery:
                return .run {[stickerurl = state.stickerData?.url] send in
                    do {
                        guard let stickerurl = stickerurl, let url = URL(string: stickerurl) else {
                            return
                        }
                        let image = try await downloadImageWithKingfisher(from: url)
                        try await photoLibaryClient.saveImage(image)
                        await send(.saveLocalIsSuccess(true))
                    }
                    catch {
                        await send(.saveLocalIsSuccess(false))
                    }
                }
            case .saveLocalIsSuccess(let isSuccess):
                state.alert = AlertState {
                    TextState(isSuccess ? "저장 완료": "저장 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(isSuccess ? "성공적으로 갤러리에 저장되었습니다." : "갤러리 저장 실패했습니다.")
                }
                return .none
            }
        }.ifLet(\.$alert, action: \.alert)
    }
    private func downloadImageWithKingfisher(from url: URL) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value.image)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
}
