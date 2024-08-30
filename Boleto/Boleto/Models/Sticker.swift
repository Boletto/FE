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
    let image: String
    var position: CGPoint
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
    var isSelected: Bool = false
    var type: StickerType
    var text: String?
}
