//
//  Spot.swift
//  Boleto
//
//  Created by Sunho on 9/3/24.
//

import Foundation

enum Spot: String, CaseIterable {
    case seoul = "서울"
    case busan = "부산"
    case jeju = "제주"
    var upperString: String {
        switch self {
        case .seoul:
            "SEOUL"
        case .busan:
            "BUSAN"
        case .jeju:
            "JEJU"
        }
    }
 
}
