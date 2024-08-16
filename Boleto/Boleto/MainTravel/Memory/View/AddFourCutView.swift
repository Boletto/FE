//
//  AddFourCutView.swift
//  Boleto
//
//  Created by Sunho on 8/15/24.
//

import SwiftUI

struct AddFourCutView: View {
//    @Binding var isopen: Bool
    var body: some View {
        VStack {

            
            // Fullscreen content
            Text("Full Screen Content")
                .font(.largeTitle)
                .padding()
            
            Spacer()
        }
        .customNavigationBar(centerView: {
            Text("네컷사진 추가")
                .foregroundStyle(.black)
        }, leftView: {
            Image(systemName: "xmark")
        })

    }
}

#Preview {
    AddFourCutView()
}
