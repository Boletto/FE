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
            let width = geo.size.width
            let height = geo.size.height
            let padding = CGFloat(width / 15)
            
            ZStack {
                AsyncImageView(urlString: data.frameUrl, targetSize: nil, imagetype: .image)
                    .frame(width: width, height: height)
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
            .frame(width: width, height: height)
        }
    }
}




