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
    let isSmallMode: Bool
    var body: some View {
        VStack {
            HStack(spacing: 2) {
                KFImage.url(URL(string: data.firstPhotoUrl))
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 5 : 10))
                KFImage.url(URL(string: data.secondPhotoUrl))
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 5 : 10))
            }
            HStack(spacing: 2) {
                KFImage.url(URL(string: data.thirdPhotoUrl))
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 5 : 10))
                KFImage.url(URL(string: data.lastPhotoUrl))
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 5 : 10))
            }
        }
        .padding(.all,isSmallMode ? 8 : 16)
        .padding(.bottom,isSmallMode ? 16 : 40)
        .background(
            KFImage.url(URL(string: data.frameurl))
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 20))
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
    ), isSmallMode: true).frame(width: 128, height: 145).applyBackground(color: .background)
}
