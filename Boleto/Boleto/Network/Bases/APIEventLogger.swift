//
//  APIEventLogger.swift
//  Boleto
//
//  Created by Sunho on 9/22/24.
//

import Foundation
import Alamofire

class APIEventLogger: EventMonitor {

    let queue = DispatchQueue(label: "myNetworkLogger")

    func requestDidFinish(_ request: Request) {
      print("🛰 NETWORK Reqeust LOG")
      print(request.description)

      let url = request.request?.url?.absoluteString ?? ""
      let method = request.request?.httpMethod ?? ""
      let headers = request.request?.allHTTPHeaderFields ?? [:]
      print("URL: \(url)\nMethod: \(method)\nHeaders: \(headers)\n")
      print("Authorization: " + (request.request?.headers["Authorization"] ?? ""))
      print("Body: " + (request.request?.httpBody?.toPrettyPrintedString ?? ""))
    }

    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        print("🛰 NETWORK Response LOG")
        let url = request.request?.url?.absoluteString ?? ""
        let statusCode = response.response?.statusCode ?? 0
        let data = response.data?.toPrettyPrintedString ?? ""
        print("URL: \(url)\nResult: \(response.result)\nStatusCode: \(statusCode)\nData: \(data)")
    }
}

extension Data {
    var toPrettyPrintedString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString as String
    }
}
class API {
    static let session: Session = {
         let configuration = URLSessionConfiguration.af.default
         let apiLogger = APIEventLogger()
         return Session(configuration: configuration, eventMonitors: [apiLogger])
     }()
}
