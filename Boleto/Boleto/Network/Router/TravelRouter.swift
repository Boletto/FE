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
    case updateTravel( TravelFetchRequest, travelId: Int)
    case putTravelEdit(EditModeRequest, travelid: Int)
    case deleteTravel(travelId: Int)
    case getAllTravel(isAccepted: Bool)
    
    case patchAccept(travelId: Int)
    case patchreject(travelId: Int)
    case getOneTravel(travelID: Int)
}
extension TravelRouter: NetworkProtocol {
    
    var baseURL: String {
        return CommonAPI.api+"/api/v1/travels"
    }
    var path: String {
        switch self {
        case .postTravel:
            ""
        case .updateTravel(_, let travelId):
            "/\(travelId)"
        case .deleteTravel(let travelId):
            "/\(travelId)"
        case .getAllTravel:
            ""
        case .putTravelEdit(_, let travelId):
            "/\(travelId)/status"
        case .patchreject(let travelId):
            "/\(travelId)/reject"
        case .patchAccept(let travelId):
            "/\(travelId)/accept"
        case .getOneTravel(let travelId):
            "/\(travelId)"
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

        case .getAllTravel, .getOneTravel:
                .get
        case .putTravelEdit:
                .put
        case .patchreject, .patchAccept:
                .patch
        }
    }
    var parameters: RequestParams {
        switch self {
        case .postTravel(let travelDTO):
            return .body(travelDTO)
        case .updateTravel(let travelDTO, _):
            return .body(travelDTO)
        case .deleteTravel(let deleteDTO):
            return  .query(deleteDTO)
        case .getAllTravel(let isAccepted):
            return  .query(["isAccepted": isAccepted])
        case let .putTravelEdit(editRequest, _):
            return .body(editRequest)
        case .getOneTravel(let travelId):
            return .query(["travelId": travelId])
        default:
            return .none
        }
    }
    var multipartData: MultipartFormData? {
        return nil
    }
    
}
