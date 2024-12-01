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
    var putStickers: @Sendable ([StickerItem], [SpeechItem], Int, Int) async throws -> Void
    var postCreateTravelMemory: @Sendable (Int, Int, String, String, [Data]) async throws-> Void
    var deleteMemoryItem: @Sendable (Int, Int)  async throws -> Void
    var getTravelMemory: @Sendable (Int)  async throws -> ([SinglePhotoItem],[FourCutItem],[StickerItem],[SpeechItem])
}
extension TravelMemoryClient: DependencyKey{
    static var liveValue = Self(
        putStickers: { stickers, speechs, travelId, memoryIdx in
            let editRequest = stickers.map{$0.toEditMemoryRequest()} + speechs.map{$0.toEditMemoryRequest()}
            try await NetworkManager.request(endpoint: TravelMemoryRouter.putStickers(travelId: travelId, memoryIdx: memoryIdx, editRequest), responseType: GeneralResponse<String>.self)
            
        }, postCreateTravelMemory: {travelID, memoryIdx, memoryType, frameCode, images in
            let travelRequest = TravelMemoryPhotoRequest(memoryType: memoryType, frameCode: frameCode)
            try await NetworkManager.request(endpoint: TravelMemoryRouter.postMemoryIndex(travelId: travelID, memoryIdx: memoryIdx, travelRequest, images), responseType: GeneralResponse<String>.self)
        }, deleteMemoryItem: {travelId, memoryIdx in
            try await NetworkManager.request(endpoint: TravelMemoryRouter.deleteMemoryIndex(travelId: travelId, memoryIdx: memoryIdx), responseType: GeneralResponse<String>.self)
        }, getTravelMemory: {travelID in
            let response = try await NetworkManager.request(endpoint: TravelMemoryRouter.getMemory(travelId: travelID), responseType: GeneralResponse< MemoryResponse>.self)
            guard let data = response.data else {throw CustomError.invalidResponse}
            let singlePhotoItems = data.memories.filter{$0.memoryType == "PICTURE"}.map{
                SinglePhotoItem(frameCode: $0.frameCode, pictureIdx: $0.memoryIdx, imageURL: $0.pictures.first ?? "")
            }
            let fourCutItems = data.memories.compactMap {
                $0.memoryType == "FOUR_CUT" ? FourCutItem(index: $0.memoryIdx, frameurl: $0.frameCode, picturesURL: $0.pictures) : nil
            }
            let stickerItems = data.stickers.filter {$0.stickerType == "STICKER"}.map{
                StickerItem(id: UUID(), name: $0.content, stickerCode: $0.stickerCode, image: URL(string: $0.stickerURL)!, position: CGPoint(x: $0.locX, y: $0.locY),scale: CGFloat($0.scale),rotation: Angle(degrees: Double($0.rotation)))
            }
            let speechItems = data.stickers.filter {$0.stickerType == "SPEECH"}.map{
                SpeechItem(id: UUID(), name: "", stickerCode: $0.stickerCode, image: URL(string: $0.stickerURL)!, position:  CGPoint(x: $0.locX, y: $0.locY),scale: CGFloat($0.scale),rotation: Angle(degrees: Double($0.rotation)), text: $0.content)
            }
            return (singlePhotoItems,fourCutItems,stickerItems,speechItems)
        }
        )
    
    
}
