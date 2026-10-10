//
//  ShareCodeResponse.swift
//  Boleto
//
//  Created by Sunho on 11/14/24.
//

import Foundation
struct ShareCodeResponse: Decodable {
    let friendCode: String
    let userNickname: String
    let expireDate: String
    enum CodingKeys: String, CodingKey {
        case friendCode = "friend_code"
        case userNickname = "user_nickname"
        case expireDate = "expire_date"
    }
}
