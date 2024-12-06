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
    ) async throws -> T {
        let task = API.session.request(endpoint, interceptor: RequestTokenInterceptor())
            .validate()
            .serializingDecodable(T.self)
        
        do {
            let response = try await task.value
            return response
        } catch let error as CustomError {
            if case .expiredRefreshToken = error {
                NotificationCenter.default.post(name: Notification.Name("didLogout"), object: nil)
            }
            throw error
        }
    }
//    static func uploadMultipart
}
