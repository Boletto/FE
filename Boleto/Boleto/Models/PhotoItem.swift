//
//  PhotoItem.swift
//  Boleto
//
//  Created by Sunho on 8/28/24.
//

import SwiftUI
struct SinglePhotoItem: Equatable {
    var frameCode: String
    var pictureIdx: Int
    var imageURL: String
    
    init( frameCode: String, pictureIdx: Int, imageURL: String) {
        self.frameCode = frameCode
        self.pictureIdx = pictureIdx
        self.imageURL = imageURL
    }
}
//extension PhotoItem {
//    static let mock = Self(id: 2, image: Image("logo"), pictureIdx: 1, imageURL: "https://picsum.photos/300")
//}
