//
//  PhotoGridItem.swift
//  Boleto
//
//  Created by Sunho on 10/1/24.
//

import Foundation
enum PhotoGridItem: Identifiable, Equatable {
    case singlePhoto(PhotoItem)
    case fourCut(FourCutModel)
    var id: Int? {
        switch self {
        case .singlePhoto(let item):
            return item.id
        case .fourCut(let item):
            return item.id
        }
    }
}
