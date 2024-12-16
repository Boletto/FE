//
//  FourCutView.swift
//  Boleto
//
//  Created by Sunho on 10/1/24.
//

import SwiftUI
import Kingfisher
import ComposableArchitecture
import SwiftData

struct FourCutView: View {
    let data: FourCutItem
    let isSmallMode: Bool
    @Dependency(\.databaseClient.context) private var context
    
    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let padding = CGFloat(screenWidth / 15)
            let imageSize = padding * 6
            ZStack {
                KFImage.url(URL(string: data.frameUrl))
                    .resizable()
                    .aspectRatio(0.86, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 20 : 10))
                    .clipped()
            VStack(spacing: padding) {
                HStack(spacing: padding) {
                    KFImage.url(URL(string: data.picturesURL[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))
                    KFImage.url(URL(string: data.picturesURL[1]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))
                    
                }
                HStack(spacing:  padding) {
                    KFImage.url(URL(string: data.picturesURL[2]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))
                    
                    KFImage.url(URL(string: data.picturesURL[3]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))
                }
            }
            .padding(.all, padding)
            .padding(.bottom, padding * 1.5)
            }
        }
    }
}


