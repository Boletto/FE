//
//  Array+.swift
//  Boleto
//
//  Created by Sunho on 9/23/24.
//

import Foundation
extension Array where Element == TravelResponse {
    func toTicket() -> [Ticket] {
        return self.map {res in
            autoreleasepool {
                res.toTicket()
            }
        }
    }
    
}
extension Array {

    func chunked(into size: Int) -> [[Element]] {
        guard size > 0, !isEmpty else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
