//
//  FloatingButton.swift
//  Boleto
//
//  Created by Sunho on 8/14/24.
//

import SwiftUI

struct FloatingButton: View {
    let symbolName: String?
    let imageName: String?
    let isEditButton: Bool
    let action: () -> Void
  
    var body: some View {
        Button(action : action) {
            if let symbolName = symbolName {
                Image(systemName: symbolName)
                    .resizable()
                    .frame(width: 21, height: 21)
            }
            else if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 23, height: 23)
            }
        }.buttonStyle(FloatingButtonStyle(isEditButton: isEditButton))
    }
}
struct FloatingButtonStyle: ButtonStyle {
    let isEditButton: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
//            .font(.title3)
            .foregroundColor(.gray1)
            .frame(width: 51, height: 51)
            .background(
                Circle()
                    .fill(isEditButton ? Color.mainColor : Color.white)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
