//
//  RequestTokenInterceptor.swift
//  Boleto
//
//  Created by Sunho on 9/22/24.
//

import Alamofire
import Foundation
final class RequestTokenInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        guard let accessToken = KeyChainManager.shared.read(key: .accessToken) else {
            return
        }
        var urlRequest = urlRequest
        urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        completion(.success(urlRequest))
    }
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        // accessToken만료되었을때 코드 작성 RefreshTokenAPI.refreshToken
        guard let refreshToken = KeyChainManager.shared.read(key: .refreshToken) else {return}
        
                
    }
}
