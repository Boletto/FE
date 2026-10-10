//
//  TTIRequest.swift
//  Boleto
//
//  Created by Sunho on 4/27/25.
//

import Foundation
struct TTIRequest: Encodable {
    let actionType: String
    let actionDetail:String
    enum CodingKeys: String, CodingKey {
        case actionType = "action_type"
        case actionDetail = "action_details"
    }
}
