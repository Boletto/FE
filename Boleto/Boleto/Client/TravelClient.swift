//
//  TravelClient.swift
//  Boleto
//
//  Created by Sunho on 9/22/24.
//

import Foundation
import Alamofire
import ComposableArchitecture

@DependencyClient
struct TravelClient{
    var postLogin: @Sendable (TravelRequest) async throws -> Bool
}
extension TravelClient : DependencyKey {
    static var liveValue: Self = {
        return Self(
            postLogin: { request in
                try await API.session.request(TravelRouter.postTravel(request), interceptor: RequestTokenInterceptor())
                    .response { data in
                        print(data)
                    }
                    .serializingDecodable()
                    .value
//                    .responseDecodable(of: GeneralResponse<EmptyData>.self) { respons in
//                        switch respons.result {
//                        case .success(let res):
//                            return true
//                        case .failure(err):
//                            return false
//                        }
//                    }
        })
    }()
}
extension DependencyValues {
    var travelClient: TravelClient {
        get { self[TravelClient.self] }
        set { self[TravelClient.self] = newValue }
    }
}
