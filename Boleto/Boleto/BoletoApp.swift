//
//  BoletoApp.swift
//  Boleto
//
//  Created by Sunho on 8/9/24.
//

import SwiftUI

@main
struct BoletoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
//                .background(Color.background)
                .onAppear {
                    for family: String in UIFont.familyNames {
                                    print(family)
                                    for names : String in UIFont.fontNames(forFamilyName: family){
                                        print("=== \(names)")
                                    }
                                }
                }
        }
    }
}
