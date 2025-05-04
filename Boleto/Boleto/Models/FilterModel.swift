//
//  FilterModel.swift
//  Boleto
//
//  Created by Sunho on 4/17/25.
//

import Foundation
struct Filter:Hashable, Equatable,Identifiable  {
    let id: UUID
    let name: String
    let metalFunction: String
    let defaultIntensity: Float
}
extension Filter {
    static var original: Filter {
        Filter(id:  UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, name: "원본", metalFunction: "", defaultIntensity: 0)
    }
}
