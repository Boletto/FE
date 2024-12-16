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
        // accessToken만료되었을때 코드 작성 RefreshTokenAPI.refreshToken
        guard
            let response = request.response,
            response.statusCode == 401,  // 401 상태 코드인지 확인
            let refreshToken = KeyChainManager.shared.read(key: .refreshToken)
        else {
            completion(.doNotRetry) // 다른 경우는 재시도하지 않음
            return
        }
        _ = API.session.request(AccountRouter.postRefreshToken(refreshToken: refreshToken))
            .validate()
            .responseDecodable(of: GeneralResponse<TokenResponse>.self) { res in
                switch res.result {
                case .success(let data):
                    guard let accessToken = data.data?.accessToken, let refreshToken = data.data?.refreshToken else{
                        completion(.doNotRetryWithError(CustomError.expiredRefreshToken))
                        return
                    }
                    if let error = data.error {
                        if error.code == 40101 {
                            completion(.doNotRetryWithError(CustomError.expiredRefreshToken))
                            return
                        }
                    }
                    KeyChainManager.shared.save(key: .accessToken, token: accessToken)
                    KeyChainManager.shared.save(key: .refreshToken, token: refreshToken)
                    completion(.retry)
                case .failure(let err):
                    completion(.doNotRetryWithError(err))
                }
            }
    }
}
