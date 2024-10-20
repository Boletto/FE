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
//    let userid: Int
    let userProfile: String
    let userName: String?
    let userNickName: String?
    enum CodingKeys: String, CodingKey {
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
//        case userid = "user_id"
        case userProfile, userName, userNickName
    }
}
