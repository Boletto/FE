//
//  FiltersResponse.swift
//  Boleto
//
//  Created by Sunho on 4/17/25.
//
import Foundation

struct FiltersResponse: Decodable {
    let filters: [FilterModelRes]
}
struct FilterModelRes: Decodable {
    let name: String
    let function: String
    let defaultIntensity: Float
    let description: String
    func toDomain() -> Filter {
        return .init(id: UUID(), name: name, metalFunction: function, defaultIntensity: defaultIntensity)
    }
}
