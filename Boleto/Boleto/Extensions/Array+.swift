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
