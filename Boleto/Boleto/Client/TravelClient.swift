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
    var getSingleMemory: @Sendable (Int) async throws -> MemoryResponse
    var postSinglePhoto: @Sendable (Int, Int, Int, Data) async throws -> Bool
    var deleteSinglePhoto: @Sendable (Int) async throws -> Bool
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
            }, getSingleMemory: { req in
                do {
                    let task = API.session.request(TravelRouter.getSingleMemory(SingleTravelRequest(travelID: req)),interceptor: RequestTokenInterceptor())
                        .validate()
                        .serializingDecodable(GeneralResponse<MemoryResponse>.self)
                    let value = try await task.value
                    if let data = value.data {
                        return data
                    } else {
                        throw NSError(domain: "TravelClientError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No travel data found"])
                    }
                }
                
            }, postSinglePhoto:  { userId, travelId, pictureIndex, imageData in
                let imageUploadRequest = ImageUploadRequest(userid: userId, travelId: travelId, pictureIdx: pictureIndex)
                guard let multipartData = TravelRouter.postSinglePicture(imageUploadRequest, imageFile: imageData).multipartData else {
                      throw NSError(domain: "MultipartDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create multipart form data"])
                  }
                let task =
                API.session.upload(multipartFormData: multipartData, with: TravelRouter.postSinglePicture(imageUploadRequest, imageFile: imageData),interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<EmptyData>.self)
                let response = try await task.result
                switch response {
                case .success(let success):
                    return true
                case .failure(let failure):
                    throw failure
                }
            }, deleteSinglePhoto: { req in
                let request = SignlePictureRequest(picutreId: req)
                let task = API.session.request(TravelRouter.deleteSinglePicture(request), interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<EmptyData>.self)
                switch await task.result {
                case .success(let success):
                    return true
                case .failure(let failure):
                    throw failure
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
