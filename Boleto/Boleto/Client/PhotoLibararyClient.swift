//
//  PhotoLibararyClient.swift
//  Boleto
//
//  Created by Sunho on 10/3/24.
//

import SwiftUI
import Photos
import ComposableArchitecture
struct PhotoLibararyClient {
    var saveImage: @Sendable (UIImage) async throws -> Bool
    enum PhotoError:  Error {
        case notPermitted
    }
}
extension PhotoLibararyClient: DependencyKey {
    static let liveValue = Self(saveImage: { req in
        try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for:.addOnly) { status in
            switch status {
            case .authorized, .limited :
                UIImageWriteToSavedPhotosAlbum(req, nil, nil, nil)
                continuation.resume(returning: true)
            default:
                continuation.resume(throwing: PhotoError.notPermitted)
            }
        }}
    })
}
extension DependencyValues {
    var photoLibrary: PhotoLibararyClient {
        get { self[PhotoLibararyClient.self] }
        set { self[PhotoLibararyClient.self] = newValue }
    }
}
