//
//  String+.swift
//  Boleto
//
//  Created by Sunho on 9/24/24.
//

import Foundation
extension String {
    private static let dateFormatter: DateFormatter = {
         let formatter = DateFormatter()
         formatter.locale = Locale(identifier: "ko_KR")
         formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
         return formatter
     }()
    static func toDate(from dateString: String, format: String = "yyyy-MM-dd") -> Date? {
         dateFormatter.dateFormat = format
         return dateFormatter.date(from: dateString)
     }

    static func convertToFormattedDate(from dateString:String) -> String? {
        let year = String(dateString.prefix(4))
       let month = String(dateString[dateString.index(dateString.startIndex, offsetBy: 5)..<dateString.index(dateString.startIndex, offsetBy: 7)])
       let day = String(dateString[dateString.index(dateString.startIndex, offsetBy: 8)..<dateString.index(dateString.startIndex, offsetBy: 10)])
       
       // yyyy.MM.dd 형식으로 조합
       return "\(year).\(month).\(day)"
    }
}
