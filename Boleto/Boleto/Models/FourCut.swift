//
//  FourCut.swift
//  Boleto
//
//  Created by Sunho on 10/1/24.
//

import Foundation
struct FourCutModel: Equatable {
    let frameurl: String
    let isDefault: Bool
    let firstPhotoUrl: String
    let secondPhotoUrl: String
    let thirdPhotoUrl: String
    let lastPhotoUrl: String
    let id: Int
    let index: Int
}
extension FourCutModel {
     static let mock = Self(frameurl: "https://picsum.photos/300", isDefault: false, firstPhotoUrl: "https://picsum.photos/300", secondPhotoUrl: "https://picsum.photos/300", thirdPhotoUrl: "https://picsum.photos/300", lastPhotoUrl: "https://picsum.photos/300", id: 1, index: 1)
}
