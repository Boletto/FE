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
        case .failure(let err):
            if case let .responseValidationFailed(reason) = err,
               case let .customValidationFailed(error) = reason,
               let customError = error as? CustomError {
                throw customError
            }
            throw CustomError.unknownError("HI오냠냐냐")
        }
    }
    
}
