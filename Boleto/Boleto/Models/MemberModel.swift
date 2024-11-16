//
//  MemberModel.swift
//  Boleto
//
//  Created by Sunho on 10/3/24.
//

import Foundation
struct MemberModel: Equatable, Identifiable {
    let id: Int
    let name: String
    let nickname :String
    let imageUrl: String?
}
extension MemberModel{
    static let dummy = MemberModel(id: 12, name: "선호", nickname: "선데이", imageUrl: "")
}
