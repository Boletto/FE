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
    var postTravel: @Sendable (TravelRequest) async throws -> Void
    var getAlltravel: @Sendable (Bool) async throws -> [Ticket]
    var getOneTravel: @Sendable (Int) async throws -> Ticket
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
                do {
                    let result =  try await NetworkManager.request(endpoint: TravelRouter.postTravel(request), responseType: String.self)
                } catch let error as CustomError{
                    print(error)
                    throw error
                }
            },
            getAlltravel: { isAccepted in
                let data = try await NetworkManager.request(endpoint: TravelRouter.getAllTravel(isAccepted: isAccepted), responseType: [TravelResponse].self)

                return data.toTicket()

            },getOneTravel: { travelID in
                let data = try await NetworkManager.request(endpoint: TravelRouter.getOneTravel(travelID: travelID), responseType: TravelResponse.self)
                return data.toTicket()
            },
            deleteTravel: { travelID in
               let res =  try await NetworkManager.request(
                    endpoint: TravelRouter.deleteTravel(travelId: travelID),
                    responseType: EmptyData.self
                )
                return true
            }, putEditmodeTravel: { lock, travelid in
                let response = try await NetworkManager.request(
                                    endpoint: TravelRouter.putTravelEdit(EditModeRequest(status: lock), travelid: travelid),
                                    responseType: EmptyData.self
                                )
//                guard response.success else {
//                    
//                }
            }, patchTravel: { request, travelId in
                let _ = try await NetworkManager.request(
                    endpoint: TravelRouter.updateTravel(request, travelId: travelId),
                    responseType: String.self
                )
                return true
            }, acceptTravel: {travelId in
                let _ = try await NetworkManager.request(endpoint: TravelRouter.patchAccept(travelId: travelId), responseType: EmptyData.self)
            }, rejectTravel: {travelId in
                let _ = try await NetworkManager.request(endpoint: TravelRouter.patchreject(travelId: travelId), responseType: EmptyData.self)
                
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
