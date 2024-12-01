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
    case updateTravel(TravelFetchRequest)
    case putTravelEdit(EditModeRequest, travelid: Int)
    case deleteTravel(SingleTravelRequest)
    case getAllTravel
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
        case .putTravelEdit(_, let travelId):
            "/\(travelId)/status"
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

        case .getAllTravel:
                .get
        case .putTravelEdit:
                .put
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
        case let .putTravelEdit(editRequest, travelid):
            return .body(editRequest)
        }
    }
    var multipartData: MultipartFormData? {
        return nil
//        switch self {
//        case .postSinglePicture(let imageRequest, let imageFile):
//            let multiPart = MultipartFormData()
//            let dataDict = imageRequest.toDictionary()
//            let fileName = String( imageRequest.travelId * 10 + imageRequest.pictureIdx)
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: dataDict)
//                multiPart.append(jsonData, withName: "data", mimeType: "application/json")
//            } catch {
//                return nil
//            }
//            multiPart.append(imageFile,withName: "picture_file", fileName: fileName, mimeType: "image/jpeg")
//            
//            
//            return multiPart
//        case .postFourPicture(let fourRequest, let imageFiles):
//            let multiPart = MultipartFormData()
//            let jsonData = Data()
//            let dataDict = fourRequest.toDictionary()
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: dataDict)
//                multiPart.append(jsonData, withName: "data", mimeType: "application/json")
//            } catch {
//                return nil
//            }
//            for (index, imageFile) in imageFiles.enumerated() {
//                let fileName = String(fourRequest.travelId * 10 + fourRequest.pictureIdx) + "_\(index + 1)"
//                multiPart.append(imageFile, withName: "picture_file", fileName: fileName, mimeType: "image/jpeg")
//            }
//            var totalSize: Int = 0
//              
//              // Size of JSON data
//              totalSize += jsonData.count
//              
//              // Size of each image
//              for imageFile in imageFiles {
//                  totalSize += imageFile.count
//              }
//              
//              // Estimate some extra overhead from multipart boundaries (about 500 bytes per part)
//              let overheadEstimate = 500 * (imageFiles.count + 1)  // +1 for the JSON part
//              totalSize += overheadEstimate
//              
//              print("Total request size: \(Double(totalSize) / 1024.0 / 1024.0) MB")
//            return multiPart
//        default:
//            return nil
//        }
    }
    
}
