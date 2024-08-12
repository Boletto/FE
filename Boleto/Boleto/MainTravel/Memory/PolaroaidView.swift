//
//  PolaroidView.swift
//  Boleto
//
//  Created by Sunho on 8/12/24.
//

import SwiftUI

import ComposableArchitecture
struct PolaroaidView: View {
    let imageView: Image
    var body: some View {
        ZStack {
            imageView
                .resizable()
                .clipShape(.rect(cornerRadius: 10))
                .padding(.top, 8)
                .padding(.horizontal, 8)
                .padding(.bottom, 40)

        }.background(Color.black.opacity(0.8))
    }
}
//#Preview {
//    PolaroaidView()
//}
