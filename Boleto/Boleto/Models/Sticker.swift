//
//  Sticker.swift
//  Boleto
//
//  Created by Sunho on 8/25/24.
//

import SwiftUI
struct Sticker: Identifiable, Equatable {
    enum StickerType {
        case regular
        case bubble
    }
    let id: UUID
    let image: StickerImage
    var position: CGPoint
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
    var isSelected: Bool = false
    var type: StickerType
    var text: String?
}

extension Sticker {
    func toStickerRequest() -> StickerRequest? {
        switch self.type {
        case .regular:
            return .init(field: self.image.rawValue, locX: Double(self.position.x), locY: Double(self.position.y), rotation: Int(self.rotation.degrees), scale: Int(self.scale * 100))
        case .bubble:
            return nil
        }
       
    }
    func toSpeechRequest() -> SpeechRequest? {
        switch self.type {
        case .bubble:
            guard let text = self.text  else {return nil}
            return .init(text: text, locX: Double(self.position.x), locY: Double(self.position.y), rotation: Int(self.rotation.degrees), scale: Int(self.scale * 100))
        case .regular:
            return nil
        }

    }
}
