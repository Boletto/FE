//
//  LoginUser.swift
//  Boleto
//
//  Created by Sunho on 9/21/24.
//

import Foundation
struct LoginUser: Encodable {
    let serialId: String
    let provider: String
    let nickname: String
}
