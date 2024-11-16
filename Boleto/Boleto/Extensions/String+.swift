//
//  String+.swift
//  Boleto
//
//  Created by Sunho on 9/24/24.
//

import Foundation
extension String {
    func toDate(format: String = "yyyy-MM-dd") -> Date? {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "ko_KR")  // 한국 로케일
         dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")  // 한국 시간대
         return dateFormatter.date(from: self)
     }
    func isoToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")  // 한국 로케일
         dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")  // 한국 시간대
        return dateFormatter.date(from: self)
        
    }
    
 
}
