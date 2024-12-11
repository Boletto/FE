//
//  PolaroidView.swift
//  Boleto
//
//  Created by Sunho on 8/12/24.
//

import SwiftUI
import Kingfisher

struct PolaroidView: View {
    let imageURL: String
    var body: some View {
        GeometryReader { geo in
            let screenWidth = Int(geo.size.width)
            let padding = CGFloat(screenWidth / 12)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.background)
                KFImage.url(URL(string: imageURL))
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(.rect(cornerRadius:  5))
                    .padding(.all, padding)
                    .padding(.bottom,padding * 1.5 )
            }
        }

    }
}
#Preview {
    PolaroidView(imageURL: "https://boletto.s3.ap-northeast-2.amazonaws.com/231_1")
        .frame(width: 128,height: 145)
}
