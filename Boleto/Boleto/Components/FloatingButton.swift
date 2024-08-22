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
                    .frame(width: 21, height: 21)
            }
        }.buttonStyle(FloatingButtonStyle(isEditButton: isEditButton))
    }
}
struct FloatingButtonStyle: ButtonStyle {
    let isEditButton: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.title3)
            .foregroundStyle(isEditButton ? Color.white : Color.mainColor)
            .padding()
            .background(isEditButton ? Color.mainColor : Color.white)
            .clipShape(Circle())

            
    }
}
