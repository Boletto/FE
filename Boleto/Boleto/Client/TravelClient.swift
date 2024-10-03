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
    var getSingleTravel: @Sendable (Int) async throws -> (Ticket, Bool)
    var getSingleMemory: @Sendable (Int) async throws -> ([FourCutModel],[PhotoItem],[Sticker], Bool)
    var postSinglePhoto: @Sendable ( Int, Int, Data) async throws -> (Int, String)
    var postFourPhoto: @Sendable (Int, Int, Int, [Data]) async throws -> FourCutModel
    var deleteSinglePhoto: @Sendable (Int,Int, Bool) async throws -> Bool
    var patchMemory: @Sendable (Int, Bool, IdentifiedArrayOf<Sticker>) async throws -> Bool
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
                        if let ableEdit = travelData.status {
                            if ableEdit == "UNLOCK" {
                                return (travelData.toTicket(), true)
                            }else {
                                return (travelData.toTicket(), false)
                            }
                            
                        } else {
                            return (travelData.toTicket(), false)
                        }
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
                        let fourCutModels = data.fourCutList.map { fourData in
                            let relatedPictures = data.pictureList.filter {$0.pictureIdx == fourData.pictureIdx}
                            let firstPhotoUrl = relatedPictures.indices.contains(0) ? relatedPictures[0].pictureUrl : ""
                            let secondPhotoUrl = relatedPictures.indices.contains(1) ? relatedPictures[1].pictureUrl : ""
                                          let thirdPhotoUrl = relatedPictures.indices.contains(2) ? relatedPictures[2].pictureUrl : ""
                                          let lastPhotoUrl = relatedPictures.indices.contains(3) ? relatedPictures[3].pictureUrl : ""
                            return FourCutModel(frameurl: fourData.frameType, isDefault: fourData.collecId <= 3 ? true : false, firstPhotoUrl: firstPhotoUrl, secondPhotoUrl: secondPhotoUrl, thirdPhotoUrl: thirdPhotoUrl, lastPhotoUrl: lastPhotoUrl, id: fourData.fourCutID , index: fourData.pictureIdx)
                        }
                        let fourCutPictureIds = data.fourCutList.map { $0.pictureIdx }
                        let singlePhotoItems = data.pictureList
                                       .filter { pictureDTO in
                                           !fourCutPictureIds.contains(pictureDTO.pictureIdx)  // 네컷에 포함되지 않은 사진만 필터링
                                       }
                                       .map { pictureDTO in
                                           PhotoItem(id: pictureDTO.pictureId, image: nil, pictureIdx: pictureDTO.pictureIdx, imageURL: pictureDTO.pictureUrl)
                                       }

                        let stickers = data.parseToStickers()
                        return (fourCutModels, singlePhotoItems, stickers, data.status == "LOCK" ? true: false)
                    } else {
                        throw NSError(domain: "TravelClientError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No travel data found"])
                    }
                }
                
            }, postSinglePhoto:  {  travelId, pictureIndex, imageData in
                let imageUploadRequest = ImageUploadRequest( travelId: travelId, pictureIdx: pictureIndex, isFourcut: false)
                let router = TravelRouter.postSinglePicture(imageUploadRequest, imageFile: imageData)
                guard let multipartData = router.multipartData else {
                      throw NSError(domain: "MultipartDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create multipart form data"])
                  }
                let task =
                API.session.upload(multipartFormData: multipartData, with: router,interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<PictureDTO>.self)
                guard let value = try await task.value.data else { throw CustomError.invalidResponse}
                let response = try await task.result
                switch response {
                case .success(let success):
                    return (value.pictureId, value.pictureUrl)
                case .failure(let failure):
                    throw failure
                }
            },postFourPhoto: { travelId, pictureIdx, collectID, datas in
                let req = FourCutRequest(travelId: travelId, pictureIdx: pictureIdx, isFourcut: true, collectId: collectID)
                guard let multipartData = TravelRouter.postFourPicture(req, imageFile: datas).multipartData else {
                    throw NSError(domain: "MultipartDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create multipart form data"])
                }
                let task =
                API.session.upload(multipartFormData: multipartData, with: TravelRouter.postFourPicture(req, imageFile: datas),interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<PostFourCutResponse>.self)
                guard let value = try await task.value.data else { throw CustomError.invalidResponse}
                let response = try await task.result
                switch response {
                case .success(let success):
                    guard let data = success.data else {throw CustomError.invalidResponse}
                    guard let pictureURLS = data.pictureUrl else {throw CustomError.invalidResponse}
                    let result = FourCutModel(frameurl: data.frameType, isDefault: data.collecId <= 3 ? true : false, firstPhotoUrl: pictureURLS[0], secondPhotoUrl: pictureURLS[1], thirdPhotoUrl: pictureURLS[2], lastPhotoUrl: pictureURLS[3], id: data.fourCutID, index: data.pictureIdx)
                    return result
                case .failure(let failure):
                    throw failure
                }
                
            },
            deleteSinglePhoto: { travelId, pictureIdx, isFourCut in
                let request = SignlePictureRequest(picutreIdx: pictureIdx, travelId: travelId, isFourCut: isFourCut)
                let task = API.session.request(TravelRouter.deleteSinglePicture(request), interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<EmptyData>.self)
                switch await task.result {
                case .success(let success):
                    return true
                case .failure(let failure):
                    throw failure
                }
            }, patchMemory: { travelId , editmode, stickers in
                let stickerRequests = stickers.compactMap {$0.toStickerRequest()}
                let speechRequests = stickers.compactMap {$0.toSpeechRequest()}
                let req = EditMemoryRequest(travelId: travelId,  status: editmode ? "UNLOCK" : "LOCK", stickerList: stickerRequests, speechList: speechRequests)
                let task = API.session.request(TravelRouter.patchEditData(req), interceptor: RequestTokenInterceptor())
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
