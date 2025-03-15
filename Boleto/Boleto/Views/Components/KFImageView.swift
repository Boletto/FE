//
//  KFImageView.swift
//  Boleto
//
//  Created by Sunho on 3/6/25.
//

import SwiftUI
import Kingfisher

struct KFImageView : View {
    let url: URL
    let processor = DownsamplingImageProcessor(size: .init(width: 320, height: 320))
    var body: some View {
        KFImage(url)
            .setProcessor(processor)
            .diskCacheExpiration(.seconds(4 * 24 * 60 * 60))
            .placeholder {
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle())
            }
            .resizable()

            .scaledToFill()
    }
    
}
struct KFStickerView : View {
    let url: URL
    let processor = DownsamplingImageProcessor(size: .init(width: 240, height: 240))
    
    var body: some View {
        KFImage(url)
            .setProcessor(processor)
            .diskCacheExpiration(.days(30))
            .loadDiskFileSynchronously()
            .placeholder {
                ProgressView()
            }
            .resizable()
            .scaledToFit()
    }
}
