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
//enum PhotoItemType: Equatable {
//    case single(Polaroid)
//    case fourCut(FourCut)
//}
//struct PhotoItem: Identifiable, Equatable {
//    let id: Int
//    let type: PhotoItemType
//    var image: Image?
//    var pictureIdx: Int
//    var imageURL: String?
//    
//    init(id: Int, image: Image?, pictureIdx: Int, imageURL: String?) {
//        self.id = id
//        self.image = image
//        self.pictureIdx = pictureIdx
//        self.imageURL = imageURL
//    }
//}
//struct Polaroid: Equatable {
//    let pictureUrl: String
//    
//}
//struct FourCut: Equatable {
//    let pictureurls: [String]
//    let frametype: String
//    let id: Int
//    let index: Int
//    
//}
