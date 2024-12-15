//
//  NetworkManager.swift
//  Boleto
//
//  Created by Sunho on 12/1/24.
//
import Alamofire
import SwiftUI

struct NetworkManager {
    static func request<T: Decodable>(
        endpoint: URLRequestConvertible,
        responseType: T.Type
    ) async throws (CustomError) -> T {
        let task = API.session.request(endpoint, interceptor: RequestTokenInterceptor())
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self)
        
        do {
            let response = try await task.value
            return response
        } catch let error as AFError{
            switch error {
            case .requestRetryFailed(let retryError, _ ):
                if let customError = retryError as? CustomError {
                    throw customError
                } else {
                    throw CustomError.unknownError
                }
            default:
                throw CustomError.unknownError
            }
        } catch {
            throw CustomError.unknownError
        }
    }
//    static func uploadMultipart
}
