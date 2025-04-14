//
//  FourCutView.swift
//  Boleto
//
//  Created by Sunho on 10/1/24.
//

import SwiftUI
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
            ZStack {
                AsyncImageView(urlString: data.frameUrl, targetSize: nil, imagetype: .image)
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 20 : 10))
                    .clipped()
                VStack(spacing: padding) {
                    HStack(spacing: padding) {
                        AsyncImageView(urlString: data.picturesURL[0], targetSize: CGSize(width: 480, height: 480), imagetype: .image)
                            .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))
                        AsyncImageView(urlString: data.picturesURL[1], targetSize: CGSize(width: 480, height: 480), imagetype: .image)
                            .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))
                        
                    }
                    HStack(spacing: padding) {
                        AsyncImageView(urlString: data.picturesURL[2], targetSize: CGSize(width: 480, height: 480), imagetype: .image)
                            .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))
                        
                        AsyncImageView(urlString: data.picturesURL[3], targetSize: CGSize(width: 480, height: 480), imagetype: .image)
                            .clipShape(RoundedRectangle(cornerRadius: isSmallMode ? 10 : 5))
                    }
                }
                .padding(.all, padding)
                .padding(.bottom, padding * 1.5)
            }
        }
        .aspectRatio(0.87, contentMode: .fit) // 그리드 아이템의 width/height 비율(0.3/0.345)에 맞춤
    }
}




