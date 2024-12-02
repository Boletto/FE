//
//  PhotoGridItem.swift
//  Boleto
//
//  Created by Sunho on 10/1/24.
//

import Foundation
enum PhotoGridItem: Equatable {
    case singlePhoto(SinglePhotoItem)
    case fourCut(FourCutItem)
    
//    var id: Int {
//        switch self {
//        case .singlePhoto(let item):
//            return item.id
//        case .fourCut(let item):
//            return item.id
//        }
//    }
    
    var frameCode: String {
        switch self {
        case .singlePhoto(let item):
            return item.frameCode
        case .fourCut(let item):
            return item.frameCode
        }
    }
    
    var isFourCut: Bool {
        if case .fourCut = self {
            return true
        }
        return false
    }
}

struct FourCutItem: Equatable {
    let index: Int
    let frameCode: String
    let picturesURL: [String]
}
struct SinglePhotoItem: Equatable {
    var pictureIdx: Int
    var frameCode: String
    var imageURL: String
}
