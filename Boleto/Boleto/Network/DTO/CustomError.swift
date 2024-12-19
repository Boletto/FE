//
//  CustomError.swift
//  Boleto
//
//  Created by Sunho on 9/27/24.
//

import Foundation


enum CustomError: Error {
    case methodNotAllowed(String)
    case notFound(String)
    case badRequest(String,Int)
    case accessDenied(String)
    case conflict(String)
    case unauthorized(String)
    case internalServerError(String)
    case unknownError(String)
    case expiredRefreshToken
    // 서버 에러 코드 기반 매핑
    static func from(code: Int, message: String) -> Self {
        switch code {
        case 40500:
            return .methodNotAllowed(message)
        case 40400...40499:
            return .notFound(message)
        case 40000...40099:
            return .badRequest(message, code)
        case 40300...40399:
            return .accessDenied(message)
        case 40900...40999:
            return .conflict(message)
        case 40100...40199:
            return .unauthorized(message)
        case 50000...50099:
            return .internalServerError(message)
        default:
            return .unknownError(message)
        }
    }
    
    var message: String {
        switch self {
        case .methodNotAllowed(let message),
             .notFound(let message),
             .badRequest(let message,_),
             .accessDenied(let message),
             .conflict(let message),
             .unauthorized(let message),
             .internalServerError(let message),
             .unknownError(let message):
            return message
        case .expiredRefreshToken:
            return ""
        }
    }
}
