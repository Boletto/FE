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
    var putEditmodeTravel: @Sendable (String, Int) async throws -> Void
    var patchTravel: @Sendable (TravelFetchRequest) async throws -> Bool
}
extension TravelClient : DependencyKey {
    static var liveValue: Self = {
        return Self(
            postTravel: { request in
                try await NetworkManager.request(endpoint: TravelRouter.postTravel(request), responseType: GeneralResponse<String>.self).success
            },
            getAlltravel: {
                let response = try await NetworkManager.request(endpoint: TravelRouter.getAllTravel, responseType: GeneralResponse<[TravelResponse]>.self)
                guard let data = response.data else {throw CustomError.invalidResponse}
                return data.toTicket()

            }, deleteTravel: { travelID in
                try await NetworkManager.request(
                    endpoint: TravelRouter.deleteTravel(SingleTravelRequest(travelID: travelID)),
                    responseType: GeneralResponse<EmptyData>.self
                ).success
            }, putEditmodeTravel: { lock, travelid in
                let response = try await NetworkManager.request(
                                    endpoint: TravelRouter.putTravelEdit(EditModeRequest(status: lock), travelid: travelid),
                                    responseType: GeneralResponse<EmptyData>.self
                                )
                guard response.success else {
                    throw CustomError.alreadyLocked
                }
            }, patchTravel: { request in
                try await NetworkManager.request(
                    endpoint: TravelRouter.updateTravel(request),
                    responseType: GeneralResponse<TravelResponse>.self
                ).success
            }
          
                //patchTravel: { req in
//                do {
//                    let task = API.session.request(TravelRouter.updateTravel(req), interceptor: RequestTokenInterceptor())
//                        .validate()
//                        .serializingDecodable(GeneralResponse<EmptyData>.self)
//                    let resposne = try await task.value
//                    return resposne.success
//                    
//                }catch {
//                    print (error.localizedDescription)
//                    return false
//                }
//            },  postSinglePhoto:  {  travelId, pictureIndex, imageData in
//                let imageUploadRequest = ImageUploadRequest( travelId: travelId, pictureIdx: pictureIndex, isFourcut: false)
//                let router = TravelRouter.postSinglePicture(imageUploadRequest, imageFile: imageData)
//                guard let multipartData = router.multipartData else {
//                      throw NSError(domain: "MultipartDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create multipart form data"])
//                  }
//                let task =
//                API.session.upload(multipartFormData: multipartData, with: router,interceptor: RequestTokenInterceptor())
//                    .validate()
//                    .serializingDecodable(GeneralResponse<PictureDTO>.self)
//                guard let value = try await task.value.data else { throw CustomError.invalidResponse}
//                let response = try await task.result
//                switch response {
//                case .success(let success):
//                    return (value.pictureId, value.pictureUrl)
//                case .failure(let failure):
//                    throw failure
//                }
//            },postFourPhoto: { travelId, pictureIdx, collectID, datas in
//                let req = FourCutRequest(travelId: travelId, pictureIdx: pictureIdx, isFourcut: true, collectId: collectID)
//                guard let multipartData = TravelRouter.postFourPicture(req, imageFile: datas).multipartData else {
//                    throw NSError(domain: "MultipartDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create multipart form data"])
//                }
//                let task =
//                API.session.upload(multipartFormData: multipartData, with: TravelRouter.postFourPicture(req, imageFile: datas),interceptor: RequestTokenInterceptor())
//                    .validate()
//                    .serializingDecodable(GeneralResponse<PostFourCutResponse>.self)
//                guard let value = try await task.value.data else { throw CustomError.invalidResponse}
//                let response = try await task.result
//                switch response {
//                case .success(let success):
//                    guard let data = success.data else {throw CustomError.invalidResponse}
//                    guard let pictureURLS = data.pictureUrl else {throw CustomError.invalidResponse}
//                    let result = FourCutModel(frameurl: data.frameType, isDefault: data.collecId <= 3 ? true : false, firstPhotoUrl: pictureURLS[0], secondPhotoUrl: pictureURLS[1], thirdPhotoUrl: pictureURLS[2], lastPhotoUrl: pictureURLS[3], id: data.fourCutID, index: data.pictureIdx)
//                    return result
//                case .failure(let failure):
//                    throw failure
//                }
//                
//            },
//            deleteSinglePhoto: { travelId, pictureIdx, isFourCut in
//                let request = SignlePictureRequest(picutreIdx: pictureIdx, travelId: travelId, isFourCut: isFourCut)
//                let task = API.session.request(TravelRouter.deleteSinglePicture(request), interceptor: RequestTokenInterceptor())
//                    .validate()
//                    .serializingDecodable(GeneralResponse<EmptyData>.self)
//                switch await task.result {
//                case .success(let success):
//                    return true
//                case .failure(let failure):
//                    throw failure
//                }
//            }
//            patchMemory: { travelId , editmode, stickers in
//                let stickerRequests = stickers.compactMap {$0.toStickerRequest()}
//                let speechRequests = stickers.compactMap {$0.toSpeechRequest()}
//                let req = EditMemoryRequest(travelId: travelId,  status: editmode ? "UNLOCK" : "LOCK", stickerList: stickerRequests, speechList: speechRequests)
//                let task = API.session.request(TravelRouter.patchEditData(req), interceptor: RequestTokenInterceptor())
//                    .validate()
//                    .serializingDecodable(GeneralResponse<EmptyData>.self)
//                switch await task.result {
//                case .success(let success):
//                    return true
//                case .failure(let failure):
//                    throw failure
//                }
//            }
        )
    }()
}
//extension TravelClient {
//    static var testValue: Self = {
//        return Self(
//            postTravel: { request in
//                // 테스트용으로 항상 true 반환
//                return true
//            },
//            getAlltravel: {
//                // 테스트용으로 빈 배열 반환
//                return Ticket.mockTickets
//            },
//            deleteTravel: { travelID in
//                // 테스트용으로 항상 true 반환
//                return true
//            },
//            patchTravel: { request in
//                // 테스트용으로 항상 true 반환
//                return true
//            },
//            getSingleTravel: { travelID in
//                // 테스트용으로 임의의 Ticket 및 Boolean 반환
//                return (Ticket.mockTickets[0], false)
//            },
//            getSingleMemory: { travelID in
//                // 테스트용으로 빈 FourCutModel, PhotoItem, Sticker 배열 및 Bool 반환
//                return ([], [], [], false)
//            },
//            postSinglePhoto: { travelID, pictureIdx, imageData in
//                // 테스트용으로 임의의 Int 및 String 반환
//                return (1, "https://example.com/image.png")
//            },
//            postFourPhoto: { travelID, pictureIdx, collectID, datas in
//                // 테스트용으로 임의의 FourCutModel 반환
//                return FourCutModel(
//                    frameurl: "testFrame",
//                    isDefault: true,
//                    firstPhotoUrl: "https://example.com/photo1.png",
//                    secondPhotoUrl: "https://example.com/photo2.png",
//                    thirdPhotoUrl: "https://example.com/photo3.png",
//                    lastPhotoUrl: "https://example.com/photo4.png",
//                    id: collectID,
//                    index: pictureIdx
//                )
//            },
//            deleteSinglePhoto: { travelID, pictureIdx, isFourCut in
//                // 테스트용으로 항상 true 반환
//                return true
//            },
//            patchMemory: { travelID, editmode, stickers in
//                // 테스트용으로 항상 true 반환
//                return true
//            }
//        )
//    }()
//}
extension DependencyValues {
    var travelClient: TravelClient {
        get { self[TravelClient.self] }
        set { self[TravelClient.self] = newValue }
    }
}
