//
//  TravelMemoryRouter.swift
//  Boleto
//
//  Created by Sunho on 12/1/24.
//

import Foundation
import Alamofire

enum TravelMemoryRouter {
    case putStickers(travelId: Int, [EditMemoryRequest])
    case postMemoryIndex(travelId: Int, memoryIdx: Int, TravelMemoryPhotoRequest, [Data])
    case deleteMemoryIndex(travelId: Int, memoryIdx: Int)
    case getMemory(travelId: Int)
//    case post
}
extension TravelMemoryRouter: NetworkProtocol {
    var baseURL: String {
        return CommonAPI.api + "/api/v1/travel"
    }
    
    var method: HTTPMethod {
        switch self {
        case .putStickers:
                .put
        case .postMemoryIndex:
                .post
        case .deleteMemoryIndex:
                .delete
        case .getMemory:
                .get
        }
    }
    
    var path: String {
        switch self {
        case .putStickers(let travelID,_):
            "/\(travelID)/memory/stickers"
        case .postMemoryIndex(let travelID, let memoryIdx, _,_):
            "/\(travelID)/memory/\(memoryIdx)"
        case .deleteMemoryIndex(let travelID, let memoryIdx):
            "/\(travelID)/memory/\(memoryIdx)"
        case .getMemory(let travelID):
            "/\(travelID)/memory"
        }
    }
    
    var parameters: RequestParams {
        switch self {
        case .putStickers(_,let request):
                .body(request)
        case .postMemoryIndex:
                .none
        case .deleteMemoryIndex:
                .none
        case .getMemory:
                .none
        }
    }
    
    var multipartData: MultipartFormData? {
        switch self {
        case .postMemoryIndex(let travelId, _, let request, let images):
            let multipartFormData = MultipartFormData()
            
            if let jsonData = try? JSONEncoder().encode(request) {
                let jsonString = String(data:jsonData, encoding: .utf8)!
                print(jsonString)
                multipartFormData.append(jsonData, withName: "updateTravelEachMemoryDto")
                    }
            for (index, imageData) in images.enumerated() {
                let fileName = String(travelId * 10 + index)
                multipartFormData.append(imageData, withName: "pictures", fileName: "image\(fileName).png", mimeType: "image/png")
            }
            print(multipartFormData)
            return multipartFormData
        default:
            return nil
        }
    }
    
    
}
