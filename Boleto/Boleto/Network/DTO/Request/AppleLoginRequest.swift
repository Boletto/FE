//
//  AppleLoginRequest.swift
//  Boleto
//
//  Created by Sunho on 9/22/24.
//

import Foundation
struct AppleLoginRequest: Encodable {
    let code: String
    let userName: String?
    enum CodingKeys: String, CodingKey {
         case code = "code"  // Mapping Swift variable to "identity_token"
        case userName = "user_name"
     }
}
