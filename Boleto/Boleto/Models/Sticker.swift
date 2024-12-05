//
//  Sticker.swift
//  Boleto
//
//  Created by Sunho on 8/25/24.
//

import SwiftUI
protocol MemoryItemProtocol: Identifiable, Equatable {
    var id: UUID { get }
    var name: String { get}
    var stickerCode: String {get}
    var image: URL { get }
    var position: CGPoint { get set }
    var scale: CGFloat { get set }
    var rotation: Angle { get set }
    var isSelected: Bool { get set }
}

struct StickerItem: MemoryItemProtocol {
    let id: UUID
    var name: String
    var stickerCode: String
    let image: URL
    var position: CGPoint
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
    var isSelected: Bool = false
    
    func toEditMemoryRequest() -> EditMemoryRequest {
        return EditMemoryRequest(stickerCode: stickerCode, locX:  position.x.roundedToDecimalPlaces(2), locY: position.y.roundedToDecimalPlaces(2 ), rotation: Int(rotation.degrees), scale: scale, content: name)
    }
    
}
struct SpeechItem: MemoryItemProtocol {
    let id: UUID
    var name: String
    var stickerCode: String
    let image: URL
    var position: CGPoint
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
    var isSelected: Bool = false
    var text: String
    func toEditMemoryRequest() -> EditMemoryRequest {
        return EditMemoryRequest(stickerCode: stickerCode, locX: position.x.roundedToDecimalPlaces(2), locY: position.y.roundedToDecimalPlaces(2 ), rotation: Int(rotation.degrees), scale: scale, content: text)
    }
}
