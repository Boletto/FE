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
    var getAlltravel: @Sendable (Bool) async throws -> [Ticket]
    var deleteTravel: @Sendable (Int) async throws -> Bool
    var putEditmodeTravel: @Sendable (String, Int) async throws -> Void
    var patchTravel: @Sendable (TravelFetchRequest, Int) async throws -> Bool
    var acceptTravel: @Sendable (Int) async throws -> Void
    var rejectTravel: @Sendable (Int) async throws -> Void
}
extension TravelClient : DependencyKey {
    static var liveValue: Self = {
        return Self(
            postTravel: { request in
                try await NetworkManager.request(endpoint: TravelRouter.postTravel(request), responseType: GeneralResponse<String>.self).success
            },
            getAlltravel: { isAccepted in
                let response = try await NetworkManager.request(endpoint: TravelRouter.getAllTravel(isAccepted: isAccepted), responseType: GeneralResponse<[TravelResponse]>.self)
                guard let data = response.data else {throw CustomError.invalidResponse}
                return data.toTicket()

            }, deleteTravel: { travelID in
                try await NetworkManager.request(
                    endpoint: TravelRouter.deleteTravel(travelId: travelID),
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
            }, patchTravel: { request, travelId in
                try await NetworkManager.request(
                    endpoint: TravelRouter.updateTravel(request, travelId: travelId),
                    responseType: GeneralResponse<TravelResponse>.self
                ).success
            }, acceptTravel: {travelId in
                try await NetworkManager.request(endpoint: TravelRouter.patchAccept(travelId: travelId), responseType: GeneralResponse<EmptyData>.self)
            }, rejectTravel: {travelId in
                try await NetworkManager.request(endpoint: TravelRouter.patchreject(travelId: travelId), responseType: GeneralResponse<EmptyData>.self)
                
            }

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
