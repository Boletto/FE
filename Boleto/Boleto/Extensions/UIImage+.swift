//
//  UIImage+.swift
//  Boleto
//
//  Created by Sunho on 3/6/25.
//

import UIKit
extension UIImage {
    func resize(targetSize: CGSize) -> UIImage? {
        let size = self.size
        let widthRatio  = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        // 비율을 유지하면서 리사이징
        let newSize = CGSize(width: size.width * min(widthRatio, heightRatio),
                            height: size.height * min(widthRatio, heightRatio))
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }
}
