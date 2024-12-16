//
//  DataRequest+.swift
//  Boleto
//
//  Created by Sunho on 12/16/24.
//

import Alamofire
import Foundation
extension DataRequest {
    func customValidate() -> Self {
        validate {request, response, data in
            let statusCode = response.statusCode
            switch statusCode {
            case 200...299:
                return .success(())
            case 401:
                return .failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode)))
            default:
                if let data = data {
                    do {
                        // 서버 에러 응답 디코딩
                        let apiResponse = try JSONDecoder().decode( GeneralResponse<EmptyData>.self, from: data)
                        if let apiError = apiResponse.error {
                            let customError = CustomError.from(code: apiError.code, message: apiError.message)
                            return .failure(customError)
                        }
                        return .failure(CustomError.unknownError("몰라디코딩"))
                    } catch {
                        return .failure(CustomError.unknownError("Unknown error"))
                    }
                }
                return .failure(CustomError.unknownError("no error data"))
                
            }
        
        }
    }
}
