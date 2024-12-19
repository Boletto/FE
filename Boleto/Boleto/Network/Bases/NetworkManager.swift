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
            .customValidate()
            .serializingDecodable(GeneralResponse<T>.self)
        let result = await task.result
        switch result {
        case .success(let data):
            guard let data = data.data else{
                throw CustomError.unknownError("모르겟다냥")
            }
            return data
        case .failure(let error):
            switch error {
            case .requestRetryFailed(let retryError, _):
                // retryError에 담긴 CustomError 추출
                if let customError = retryError as? CustomError {
                    throw customError
                }
            case .responseValidationFailed(let reason):
                if case let .customValidationFailed(error) = reason,
                   let customError = error as? CustomError {
                    throw customError
                }
            default:
                break
            }
            throw CustomError.unknownError("몬데 문제가")
            
        }
    }
    
}
