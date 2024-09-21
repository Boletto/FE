//
//  LoginResponseData.swift
//  Boleto
//
//  Created by Sunho on 9/21/24.
//

import Foundation
struct LoginResponseData: Decodable {
    let accessToken: String
    let refreshToken: String
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}
