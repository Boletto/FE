//
//  Preview.swift
//  Boleto
//
//  Created by Sunho on 9/14/24.
//

import Foundation
import SwiftData
struct Preview {
    let container: ModelContainer
    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            container =  try ModelContainer(for: BadgeData.self, configurations: config)
//            addExamples(BadgeData.dummy)
        } catch {
            fatalError("couldnot create")
        }
    }
    func addExamples(_ example: [BadgeData ]) {
        Task { @MainActor in 
            example.forEach { exam in
            container.mainContext.insert(exam)
        }}
    }
}
