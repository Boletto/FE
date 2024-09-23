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
    var getAlltravel: @Sendable () async throws -> [TravelResponse]
}
extension TravelClient : DependencyKey {
    static var liveValue: Self = {
        return Self(
            postLogin: { request in
                return try await withCheckedThrowingContinuation { continuation in
                    API.session.request(TravelRouter.postTravel(request), interceptor: RequestTokenInterceptor())
                        .response { data in
                            print(data)
                            
                        }
                        .responseDecodable(of: GeneralResponse<EmptyData>.self) { res in
                            print(res)
    //                        return true
                            continuation.resume(returning: true)
                        }
                }
           
                  
                
//                    .serializingDecodable(GeneralResponse<EmptyData>.self)
//                print (task)
//                let result = await task.result
//                print(result)
//                let value = try await task.value
//                print(value)
//                return true
//                    .response { data in
//                        print(data)
//                    }
                  
                 
//                    .responseDecodable(of: GeneralResponse<EmptyData>.self) { respons in
//                        switch respons.result {
//                        case .success(let res):
//                            return true
//                        case .failure(err):
//                            return false
//                        }
//                    }
        },
            getAlltravel: {
                return try await withCheckedThrowingContinuation { continuation in
                    API.session.request(TravelRouter.getAllTravel, interceptor: RequestTokenInterceptor())
                        .response { data in
                            print(data)
                            
                        }  .responseDecodable(of: GeneralResponse<[TravelResponse]>.self) { res in
                            print(res)
    //                        return true
                            continuation.resume(returning: res.value?.data ?? [])
                        }
                }
//                do {
//                    let task = API.session.request(TravelRouter.getAllTravel, interceptor: RequestTokenInterceptor())
//                        .validate()
//                        .serializingDecodable(GeneralResponse<[TravelResponse]>.self)
//                    let resposne = try await task.value
//                    print(resposne)
//                    return resposne.data ?? []
//                } catch {
//                    print (error.localizedDescription)
//                    if let afError = error as? AFError {
//                        switch afError {
//                        case .responseValidationFailed(let reason):
//                                                  print("Response validation failed: \(reason)")
//                                              case .responseSerializationFailed(let reason):
//                                                  print("Response serialization failed: \(reason)")
//                                              default:
//                                                  print("Other AFError: \(afError)")
//                        }
//                    }
//                    throw error
//                }
            }
        )
    }()
}
extension DependencyValues {
    var travelClient: TravelClient {
        get { self[TravelClient.self] }
        set { self[TravelClient.self] = newValue }
    }
}
