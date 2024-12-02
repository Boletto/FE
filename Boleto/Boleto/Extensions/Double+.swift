//
//  Double+.swift
//  Boleto
//
//  Created by Sunho on 12/3/24.
//

import Foundation

extension Double {
    func roundedToDecimalPlaces(_ places: Int = 3) -> Float {
        let multiplier = pow(10.0, Double(places))
        let roundedValue = (self * multiplier).rounded() / multiplier
        return Float(roundedValue)
    }
}
