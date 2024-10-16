//
//  PhotoItem.swift
//  Boleto
//
//  Created by Sunho on 8/28/24.
//

import SwiftUI
struct PhotoItem: Identifiable, Equatable {
    let id: Int
    var image: Image?
    var pictureIdx: Int
    var imageURL: String?
    
    init(id: Int, image: Image?, pictureIdx: Int, imageURL: String?) {
        self.id = id
        self.image = image
        self.pictureIdx = pictureIdx
        self.imageURL = imageURL
    }
}
