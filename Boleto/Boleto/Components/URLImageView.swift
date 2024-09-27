//
//  URLImageView.swift
//  Boleto
//
//  Created by Sunho on 9/27/24.
//

import SwiftUI
import Kingfisher

struct URLImageView: View {
    let url: URL
    var size: CGSize?
    var body: some View {
        KFImage.url(url)
            .placeholder {
                ProgressView()
            }
            .resizable()
            .frame(width: size?.width, height: size?.height)
            .aspectRatio(contentMode: .fill)
            .clipped()
    }
}
