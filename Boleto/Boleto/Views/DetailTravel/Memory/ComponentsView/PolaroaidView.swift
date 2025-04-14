//
//  PolaroidView.swift
//  Boleto
//
//  Created by Sunho on 8/12/24.
//

import SwiftUI

struct PolaroidView: View {
    let imageURL: String
    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let padding = CGFloat(screenWidth / 13)
            AsyncImageView(urlString: imageURL, targetSize: CGSize(width:400,height:400),imagetype: .image)
                    .frame(width: padding * 11)
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(.rect(cornerRadius:  5))
                    .padding(.all, padding)
                    .padding(.bottom,padding * 1.5 )
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.background)
                    }
            
        }

    }
}
#Preview {
    PolaroidView(imageURL: "https://boletto.s3.ap-northeast-2.amazonaws.com/231_1")
        .frame(width: 128,height: 145)
}
