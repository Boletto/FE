//
//  GeneralResponse.swift
//  Boleto
//
//  Created by Sunho on 9/21/24.
//

import Foundation
struct GeneralResponse<T: Decodable> : Decodable {
    let success: Bool
    let data: T?
    let error: APIError?
}
struct EmptyData: Decodable {}
