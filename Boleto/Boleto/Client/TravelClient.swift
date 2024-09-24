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
    var postTravel: @Sendable (TravelRequest) async throws -> Bool
    var getAlltravel: @Sendable () async throws -> [Ticket]
    var deleteTravel: @Sendable (Int) async throws -> Bool
    var patchTravel: @Sendable (TravelRequest) async throws -> Bool
    var getSingleTravel: @Sendable (Int) async throws -> Ticket
}
extension TravelClient : DependencyKey {
    static var liveValue: Self = {
        return Self(
            postTravel: { request in
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
            },
            getAlltravel: {
                return try await withCheckedThrowingContinuation { continuation in
                    API.session.request(TravelRouter.getAllTravel, interceptor: RequestTokenInterceptor())
                        .responseDecodable(of: GeneralResponse<[TravelResponse]>.self) { res in
                            switch res.result {
                            case .success(let response):
                                if let travelData = response.data {
                                    let tickets = travelData.toTicket()
                                    continuation.resume(returning: tickets)
                                }
                            case .failure(let error):
                                // Handle the failure and resume with error
                                continuation.resume(throwing: error)
                            }
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
            }, deleteTravel: { req in
                do {
                    let task = API.session.request(TravelRouter.deleteTravel(SingleTravelRequest(travelID: req)), interceptor: RequestTokenInterceptor())
                        .validate()
                        .serializingDecodable(GeneralResponse<EmptyData>.self)
                    let resposne = try await task.value
                    return resposne.success
                } catch {
                    print (error.localizedDescription)
                    return false
                }
            }, patchTravel: { req in
                do {
                    let task = API.session.request(TravelRouter.updateTravel(req), interceptor: RequestTokenInterceptor())
                        .validate()
                        .serializingDecodable(GeneralResponse<EmptyData>.self)
                    let resposne = try await task.value
                    return resposne.success
                    
                }catch {
                    print (error.localizedDescription)
                    return false
                }
            }, getSingleTravel:  {req in
                do {
                    let task = API.session.request(TravelRouter.getSingleTravel(SingleTravelRequest(travelID: req)), interceptor: RequestTokenInterceptor())
                        .validate()
                        .serializingDecodable(GeneralResponse<TravelResponse>.self)
                    let response = try await task.value
                    if let travelData = response.data {
                        return travelData.toTicket()
                    } else {
                        throw NSError(domain: "TravelClientError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No travel data found"])
                    }
                }
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
