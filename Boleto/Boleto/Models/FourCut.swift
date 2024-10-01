//
//  FourCut.swift
//  Boleto
//
//  Created by Sunho on 10/1/24.
//

import Foundation
struct FourCutModel:Equatable {
    let frameurl: String
    let isDefault: Bool
    let firstPhotoUrl: String
    let secondPhotoUrl: String
    let thirdPhotoUrl: String
    let lastPhotoUrl: String
    let id: Int?
    let index: Int
}
