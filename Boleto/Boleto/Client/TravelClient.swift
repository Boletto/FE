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
extension TravelClient: TestDependencyKey {
    static var testValue: Self = {
        return Self(
            postTravel: { request in
                print("Mock: postTravel called with \(request)")
            },
            getAlltravel: { _ in
                return Ticket.mockTickets
            },
            getOneTravel: { _ in
                return Ticket.mockTickets[0]
            },
            deleteTravel: { _ in
                return true
            },
            putEditmodeTravel: { _, _ in
            },
            patchTravel: { _, _ in
                return true
            },
            acceptTravel: { _ in
             
            },
            rejectTravel: { _ in
               
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
