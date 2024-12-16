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
    
    var frameUrl: String {
        switch self {
        case .singlePhoto(let item):
            return item.frameUrl
        case .fourCut(let item):
            return item.frameUrl
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
    let frameUrl: String
    let picturesURL: [String]
}
struct SinglePhotoItem: Equatable {
    var pictureIdx: Int
    var frameUrl: String
    var imageURL: String
}
