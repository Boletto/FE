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
    case getSingleMemory(SingleTravelRequest)
    case postSinglePicture(ImageUploadRequest, imageFile: Data)
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
        case .getSingleMemory:
            "/memory/get"
        case .postSinglePicture:
            "/picture/save"
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
        case .postSinglePicture:
                .post
        case .getAllTravel, .getSingleTravel, .getSingleMemory:
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
        case .getSingleMemory(let travelID):
            return .query(travelID)
        case .postSinglePicture:
            return .none
        }
    }
    var multipartData: MultipartFormData? {
        switch self {
    
        case .postSinglePicture(let imageRequest, let imageFile):
            let multiPart = MultipartFormData()
            let params = imageRequest.toDictionary()
            for (key,value) in params {
                if let valueData = "\(value)".data(using: .utf8) {
                    multiPart.append(valueData, withName: key)
                }
            }
            multiPart.append(imageFile,withName: "picture_file",fileName: "image.png", mimeType: "image/jpeg")
            return multiPart
        default:
            return nil
        }
    }
 
}
