//
//  TravelMemoryClient.swift
//  Boleto
//
//  Created by Sunho on 12/1/24.
//

import Foundation
import ComposableArchitecture
import SwiftUICore

@DependencyClient
struct TravelMemoryClient {
    var putStickers: @Sendable ([StickerItem], [SpeechItem], Int) async throws -> Void
    var postCreateTravelMemory: @Sendable (Int, Int, String, String, [Data]) async throws  -> Void
    var deleteMemoryItem: @Sendable (Int, Int)  async throws -> Void
    var getTravelMemory: @Sendable (Int)  async throws -> ([SinglePhotoItem],[FourCutItem],[StickerItem],[SpeechItem],Bool)
}
extension TravelMemoryClient: DependencyKey{
    static var liveValue = Self(
        putStickers: { stickers, speechs, travelId in
            let editRequests = stickers.map{$0.toEditMemoryRequest()} + speechs.map{$0.toEditMemoryRequest()}
            do {
                let jsonData = try JSONEncoder().encode(editRequests)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("Encoded JSON: \(jsonString)")
                }
            } catch {
                print("JSON Encoding Failed: \(error)")
            }
            let _ = try await NetworkManager.request(endpoint: TravelMemoryRouter.putStickers(travelId: travelId, editRequests), responseType: String.self)
            
        }, postCreateTravelMemory: {travelID, memoryIdx, memoryType, frameCode, images in
            let travelRequest = TravelMemoryPhotoRequest(memoryType: memoryType, frameCode: frameCode)
            let router = TravelMemoryRouter.postMemoryIndex(travelId: travelID, memoryIdx: memoryIdx, travelRequest, images)
            guard let multipartData = router.multipartData else {
                throw CustomError.unknownError("멀티파트 없습니다")
            }
            // 업로드 속도 측정 시작
                       let startTime = Date()
                       let totalSize = images.reduce(0) { $0 + $1.count } // 전체 데이터 크기 (바이트 단위)
            let response = try await NetworkManager.upload(endpoint: router, multipartData: multipartData, responseType: String.self)
            let endTime = Date()
                       let timeInterval = endTime.timeIntervalSince(startTime) // 초 단위
                       let uploadSpeed = timeInterval > 0 ? Double(totalSize) / timeInterval / 1024.0 : 0 // KB/s 단위
                       print("업로드 완료 - 소요 시간: \(String(format: "%.2f", timeInterval))초, 크기: \(totalSize) 바이트, 속도: \(String(format: "%.2f", uploadSpeed)) KB/s")
            
        }, deleteMemoryItem: {travelId, memoryIdx in
            let _ = try await NetworkManager.request(endpoint: TravelMemoryRouter.deleteMemoryIndex(travelId: travelId, memoryIdx: memoryIdx), responseType: String.self)
        }, getTravelMemory: {travelID in
            let data = try await NetworkManager.request(endpoint: TravelMemoryRouter.getMemory(travelId: travelID), responseType:  MemoryResponse.self)
            let isLocked = data.status == "LOCK"
            let singlePhotoItems = data.memories.filter{$0.memoryType == "PICTURE"}.map{
                SinglePhotoItem(pictureIdx: $0.memoryIdx, frameUrl: $0.frameUrl, imageURL: $0.pictures.first ?? "")
            }
            let fourCutItems = data.memories.compactMap {
                $0.memoryType == "FOUR_CUT" ? FourCutItem(index: $0.memoryIdx, frameUrl: $0.frameUrl, picturesURL: $0.pictures) : nil
            }
            let stickerItems = data.stickers.filter {$0.stickerType == "STICKER"}.map{
                StickerItem(id: UUID(), name: $0.content, stickerCode: $0.stickerCode, imageString:   $0.stickerURL, position: CGPoint(x: Double($0.locX)!, y: Double($0.locY)!),scale: CGFloat($0.scale),rotation: Angle(degrees: Double($0.rotation)))
            }
            let speechItems = data.stickers.filter {$0.stickerType == "SPEECH"}.map{
                SpeechItem(id: UUID(), name: "", stickerCode: $0.stickerCode, imageString:  $0.stickerURL, position:  CGPoint(x: Double($0.locX)!, y: Double($0.locY)!),scale: CGFloat($0.scale),rotation: Angle(degrees: Double($0.rotation)), text: $0.content)
            }
            return (singlePhotoItems,fourCutItems,stickerItems,speechItems, isLocked)
        }
        )
    
    
}


extension DependencyValues{
    var memoryClient: TravelMemoryClient {
        get {self[TravelMemoryClient.self]}
        set {self[TravelMemoryClient.self] = newValue}
    }
}
