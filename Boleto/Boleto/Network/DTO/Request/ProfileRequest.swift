//
//  ProfileRequest.swift
//  Boleto
//
//  Created by Sunho on 9/29/24.
//

import Foundation
struct ProfileRequest: Encodable {
    var nickName: String
    var name: String
    let profileDefault: Bool

    enum CodingKeys: String, CodingKey {
        case nickName
        case name
        case profileDefault = "profile_default"
    }
}
