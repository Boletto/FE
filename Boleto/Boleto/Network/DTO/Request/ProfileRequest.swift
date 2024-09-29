//
//  ProfileRequest.swift
//  Boleto
//
//  Created by Sunho on 9/29/24.
//

import Foundation
struct ProfileRequest: Encodable {
    var nickname: String
    var name: String
    var userProfile: String
}
