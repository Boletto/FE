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
    case deleteSinglePicture(SignlePictureRequest)
    case patchEditData(EditMemoryRequest)
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
            "/memory/picture/save"
        case .deleteSinglePicture:
            "/memory/picture/delete"
        case .patchEditData:
            "/memory/edit"
        }
    }
    var method: HTTPMethod {
        switch self {
        case .postTravel:
                .post
        case .updateTravel, .patchEditData:
                .patch
        case .deleteTravel, .deleteSinglePicture:
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
        case .deleteSinglePicture(let pictureDTO):
            return .query(pictureDTO)
        case .patchEditData(let patchDTO):
            return .body(patchDTO)
        }
    }
    var multipartData: MultipartFormData? {
        switch self {
        case .postSinglePicture(let imageRequest, let imageFile):
            let multiPart = MultipartFormData()
            let dataDict = imageRequest.toDictionary()
            do {
                         let jsonData = try JSONSerialization.data(withJSONObject: dataDict)
                         multiPart.append(jsonData, withName: "data", mimeType: "application/json")
                     } catch {
                         return nil
                     }
            multiPart.append(imageFile,withName: "picture_file",fileName: "image.png", mimeType: "image/jpeg")

            
            return multiPart
        default:
            return nil
        }
    }
 
}
