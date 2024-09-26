//
//  AppleLoginRequest.swift
//  Boleto
//
//  Created by Sunho on 9/22/24.
//

import Foundation
struct AppleLoginRequest: Encodable {
    let identityToken: String
    enum CodingKeys: String, CodingKey {
         case identityToken = "identity_token"  // Mapping Swift variable to "identity_token"
     }
}
