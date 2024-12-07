//
//  NetworkProtocol.swift
//  Boleto
//
//  Created by Sunho on 9/22/24.
//

import Alamofire
import Foundation
protocol NetworkProtocol: URLRequestConvertible {
    var baseURL: String {get}
    var method: HTTPMethod {get}
    var path: String {get}
    var parameters: RequestParams {get}
    var multipartData: MultipartFormData? {get}
}
enum RequestParams {
    case query(_ parameter: Encodable?)
    case body(_ parameter: Encodable?)
    case none
}
extension NetworkProtocol  {
    func asURLRequest() throws -> URLRequest {
        let baseurl = try baseURL.asURL()
        let url = path.isEmpty ? baseurl : baseurl.appendingPathComponent(path)
        var urlRequest = try URLRequest(url: url, method: method)
        if let multipartData  = multipartData {
            urlRequest.setValue(ContentType.multipart.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        } else {
            urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        }
        switch parameters {
        case .query(let request):
            let params = request?.toDictionary() ?? [:]
            let queryParams = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            var components = URLComponents(string: url.absoluteString)
            components?.queryItems = queryParams
            urlRequest.url = components?.url
        case .body(let request):
            if let arrayRequest = request as? [Encodable] {
                // 배열 처리
                let jsonArray = arrayRequest.compactMap { item -> [String: Any]? in
                    guard let data = try? JSONEncoder().encode(item),
                          let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                          let dictionary = jsonObject as? [String: Any] else {
                        return nil
                    }
                    return dictionary
                }
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
            } else if let singleRequest = request {
                // 단일 객체 처리
                let params = singleRequest.toDictionary() ?? [:]
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            }
            
            
        case .none:
            break
        }
        
        return urlRequest
    }
    
    
}
