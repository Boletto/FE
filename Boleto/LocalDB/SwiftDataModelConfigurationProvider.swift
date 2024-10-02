//
//  SwiftDataModelConfiguraonProvider.swift
//  Boleto
//
//  Created by Sunho on 10/2/24.
//

import SwiftData
public class SwiftDataModelConfigurationProvider {
    // Singleton instance for configuration
    public static let shared = SwiftDataModelConfigurationProvider(isStoredInMemoryOnly: false, autosaveEnabled: true)
    
    // Properties to manage configuration options
    private var isStoredInMemoryOnly: Bool
    private var autosaveEnabled: Bool
    
    // Private initializer to enforce singleton pattern
    private init(isStoredInMemoryOnly: Bool, autosaveEnabled: Bool) {
        self.isStoredInMemoryOnly = isStoredInMemoryOnly
        self.autosaveEnabled = autosaveEnabled
    }
    
    // Lazy initialization of ModelContainer
    @MainActor
    public lazy var container: ModelContainer = {
        // Define schema and configuration
        let schema = Schema(
            [
                BadgeData.self,
   
            ]
        )
        let configuration = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
        
        // Create ModelContainer with schema and configuration
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        container.mainContext.autosaveEnabled = autosaveEnabled
        return container
    }()
}
