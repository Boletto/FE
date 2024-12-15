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
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")  // 한국 로케일
         dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")  // 한국 시간대
        return dateFormatter.date(from: self)
        
    }
    func convertToFormattedDate() -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "ko_KR") // 한국 로케일
        inputFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 시간대
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy.MM.dd"
        outputFormatter.locale = Locale(identifier: "ko_KR") // 한국 로케일
        outputFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 시간대
        
        guard let date = inputFormatter.date(from: self) else {
            return nil
        }
        
        return outputFormatter.string(from: date)
    }

    
 
}
