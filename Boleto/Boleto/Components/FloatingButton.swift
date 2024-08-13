//
//  FloatingButton.swift
//  Boleto
//
//  Created by Sunho on 8/14/24.
//

import SwiftUI

struct FloatingButton: View {
    let symbolName: String
    let action: () -> Void
    var body: some View {
        Button(action : action) {
            Image(systemName: symbolName)
        }.buttonStyle(FloatingButtonStyle())
    }
}

#Preview {
    FloatingButton(symbolName: "square.and.arrow.up", action: {})
}
struct FloatingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.title3)
            .foregroundStyle(Color.mainColor)
            .padding()
            .background(Color.white)
            .clipShape(Circle())

            
    }
}
