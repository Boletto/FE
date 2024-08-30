//
//  PhotoItem.swift
//  Boleto
//
//  Created by Sunho on 8/28/24.
//

import SwiftUI
struct PhotoItem: Identifiable, Equatable {
    let id: UUID
    var image: Image
    var type: PhotoType
    
    enum PhotoType: Equatable {
        case polaroid
        case fourCut
    }
    
    init(id: UUID = UUID(), image: Image, type: PhotoType = .polaroid) {
        self.id = id
        self.image = image
        self.type = type
    }
}
