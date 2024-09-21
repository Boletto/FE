//
//  APIError.swift
//  Boleto
//
//  Created by Sunho on 9/21/24.
//

import Foundation
struct APIError: Decodable {
    let code: Int
    let message: String
}
