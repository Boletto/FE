//
//  TokenResponse.swift
//  Boleto
//
//  Created by Sunho on 12/7/24.
//

import Foundation
struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let userID: Int
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case userID = "user_id"
    }
}
