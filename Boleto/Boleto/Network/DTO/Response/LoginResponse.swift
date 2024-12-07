//
//  LoginResponseData.swift
//  Boleto
//
//  Created by Sunho on 9/21/24.
//

import Foundation
struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let userProfile: String
    let userName: String?
    let userNickName: String?
    enum CodingKeys: String, CodingKey {
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
        case userProfile, userName, userNickName
    }
}
