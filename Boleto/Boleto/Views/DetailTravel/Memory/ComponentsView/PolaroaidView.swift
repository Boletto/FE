//
//  PolaroidView.swift
//  Boleto
//
//  Created by Sunho on 8/12/24.
//

import SwiftUI
import Kingfisher
import ComposableArchitecture

struct PolaroidView: View {
//    let imageView: Image
    let imageURL: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.background)
            KFImage.url(URL(string: imageURL))
//            imageView
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .clipShape(.rect(cornerRadius:  5))
                .padding(.top, 10)
                .padding(.horizontal,  8)
                .padding(.bottom,26)
        }
    }
}
#Preview {
    PolaroidView(imageURL: "https://boletto.s3.ap-northeast-2.amazonaws.com/231_1")
        .frame(width: 128,height: 145)
}
