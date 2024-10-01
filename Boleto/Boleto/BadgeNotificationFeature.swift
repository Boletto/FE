//
//  BadgeNotificationFeature.swift
//  Boleto
//
//  Created by Sunho on 9/19/24.
//

import ComposableArchitecture
import Photos
import SwiftUI
@Reducer
struct BadgeNotificationFeature {
    @Dependency(\.dismiss) var dimisss
    
    @ObservableState
    struct State: Equatable {
        let badgeType: StickerImage
        var showAlert = false
        @Presents var alert: AlertState<Action.Alert>?
    }
    enum Action: Equatable {
        case alert(PresentationAction<Alert>)
        case saveBadgeInLocal
        case saveLocalIsSuccess(Bool)
        enum Alert:Equatable {
            
        }
    }
//    @Dependency(\.)
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .alert:
                return .none
            case .saveBadgeInLocal:
                return .run { [badgetype = state.badgeType] send in
                    do {
                        try await saveBadgeImage(badgeType: badgetype)
                        await send(.saveLocalIsSuccess(true))
                    }
                    catch {
                        await send(.saveLocalIsSuccess(false))
                    }
//                    PHPhotoLibrary.shared().performChanges {
//                        <#code#>
//                    }
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
    private func saveBadgeImage(badgeType: StickerImage) async throws {
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
