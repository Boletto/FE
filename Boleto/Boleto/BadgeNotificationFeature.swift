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
    @Dependency(\.stickerDatabase) var stickerClient
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchBadgeFromDB:
                return .run {[stickerCode = state.badgeType.rawValue] send in
                    do {
                        let stickerContext = try context()
                        // Fetch sticker data based on badgeType
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
                return .run { [badgetype = state.badgeType] send in
                    do {
                        try await saveBadgeImage(badgeType: badgetype)
                        await send(.saveLocalIsSuccess(true))
                    }
                    catch {
                        await send(.saveLocalIsSuccess(false))
                    }
                }
            case .saveLocalIsSuccess(let isSuccess):
                state.alert = AlertState(
                    title: TextState(isSuccess ? "저장 완료": "저장 실패"),
                    message: TextState(isSuccess ? "성공적으로 갤러리에 저장되었습니다." : "갤러리 저장 실패했습니다."),
                    dismissButton: .default(TextState("확인"))
                )
                return .none
            }
            
        }.ifLet(\.$alert, action: \.alert)
    }
    private func saveBadgeImage(badgeType: StickerCodes) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized else {
            throw NSError(domain: "BadgeNotificationFeature", code: 0, userInfo: [NSLocalizedDescriptionKey: "갤러리 접근 권한이 없습니다."])
        }
        
        guard let image = UIImage(named: badgeType.rawValue) else {
            throw NSError(domain: "BadgeNotificationFeature", code: 1, userInfo: [NSLocalizedDescriptionKey: "배지 이미지를 찾을 수 없습니다."])
        }
        
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
    
}
