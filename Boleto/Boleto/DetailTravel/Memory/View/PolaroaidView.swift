//
//  PolaroidView.swift
//  Boleto
//
//  Created by Sunho on 8/12/24.
//

import SwiftUI

import ComposableArchitecture

struct PolaroidView: View {
    let imageView: Image
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.background)
            imageView
                .resizable()
                .clipShape(.rect(cornerRadius:  10))
                .padding(.top, 10)
                .padding(.horizontal,  8)
                .padding(.bottom,26)
        }
    }
}
#Preview {
    PolaroidView(imageView: Image("beef"))
        .frame(width: 138,height: 138)
}
