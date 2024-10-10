//
//  FourCutView.swift
//  Boleto
//
//  Created by Sunho on 10/1/24.
//

import SwiftUI
import Kingfisher

struct FourCutView: View {
    let data: FourCutModel
    var body: some View {
        
        
        VStack {
            HStack(spacing: 2) {
                KFImage.url(URL(string: data.firstPhotoUrl))
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                KFImage.url(URL(string: data.secondPhotoUrl))
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            HStack(spacing: 2) {
                KFImage.url(URL(string: data.thirdPhotoUrl))
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                KFImage.url(URL(string: data.lastPhotoUrl))
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }.padding(.all,8)
            .padding(.bottom,16)
            .background(
                KFImage.url(URL(string: data.frameurl))
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            )
        
    }
}

#Preview {
    FourCutView(data: FourCutModel(
        frameurl: "https://boletto.s3.ap-northeast-2.amazonaws.com/3.jpg",
        isDefault: false,
        firstPhotoUrl: "https://boletto.s3.ap-northeast-2.amazonaws.com/231_1",
        secondPhotoUrl: "https://boletto.s3.ap-northeast-2.amazonaws.com/231_2",
        thirdPhotoUrl: "https://boletto.s3.ap-northeast-2.amazonaws.com/231_3",
        lastPhotoUrl: "https://boletto.s3.ap-northeast-2.amazonaws.com/231_4",
        id: 5,
        index: 1
    )).frame(width: 128, height: 145).applyBackground(color: .background)
}
