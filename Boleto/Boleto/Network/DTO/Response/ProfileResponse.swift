//
//  ProfileResponse.swift
//  Boleto
//
//  Created by Sunho on 9/30/24.
//

import Foundation
struct ProfileResponse: Decodable{
    let nickname: String
    let name: String
    let profileUrl: String
}
