//
//  BaseHeader.swift
//  Boleto
//
//  Created by Sunho on 9/22/24.
//

import Foundation
enum ContentType: String {
    case json = "application/json"
    case mutliPart = "multipart/form-data"
    // Add other content types if needed
}

enum HTTPHeaderField: String {
    case contentType = "Content-Type"
    // Add other header fields if needed
}
enum CommonAPI {
    static let api = "https://boletto.site"
}

