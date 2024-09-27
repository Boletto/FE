//
//  CustomError.swift
//  Boleto
//
//  Created by Sunho on 9/27/24.
//

import Foundation
enum CustomError: Error {
    case invalidResponse
    case networkError(Error) // If you want to wrap network errors in a custom type
}
