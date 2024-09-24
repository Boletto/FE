//
//  TravelRouter.swift
//  Boleto
//
//  Created by Sunho on 9/22/24.
//

import Alamofire
import Foundation
enum TravelRouter {
    case postTravel(TravelRequest)
    case updateTravel(TravelRequest)
    case deleteTravel(SingleTravelRequest)
    case getAllTravel
    case getSingleTravel(SingleTravelRequest)
}
extension TravelRouter: NetworkProtocol {
    var baseURL: String {
        return CommonAPI.api+"/api/v1/travel"
    }
    var path: String {
        switch self {
        case .postTravel:
            "/create"
        case .updateTravel:
            "/update"
        case .deleteTravel:
            "/delete"
        case .getAllTravel:
            "/get/all"
        case .getSingleTravel:
            "/get"
        }
    }
    var method: HTTPMethod {
        switch self {
        case .postTravel:
                .post
        case .updateTravel:
                .patch
        case .deleteTravel:
                .delete
        case .getAllTravel, .getSingleTravel:
                .get
        }
    }
    var parameters: RequestParams {
        switch self {
        case .postTravel(let travelDTO):
            return .body(travelDTO)
        case .updateTravel(let travelDTO):
            return .body(travelDTO)
        case .deleteTravel(let deleteDTO):
            return  .query(deleteDTO)
        case .getAllTravel:
            return  .none
        case .getSingleTravel(let travelID):
            return  .query(travelID)
        }
    }
 
}
