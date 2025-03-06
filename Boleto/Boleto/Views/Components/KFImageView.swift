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
    let isCollected: Bool
    let size: CGSize
    
    var body: some View {
        KFImage(url)
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: size.width, height: size.height)))
    }
    
}
