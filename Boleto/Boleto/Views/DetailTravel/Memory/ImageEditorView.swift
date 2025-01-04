//
//  ImageEditorVIew.swift
//  Boleto
//
//  Created by Sunho on 1/3/25.
//

import Foundation
import SwiftUI

struct ImageEditorView: View {
    @Environment(\.dismiss) var dismiss
    @State private var croppedImage: UIImage?
    @State private var imageViewSize: CGSize = .zero
    @State private var cropArea: CGRect = .init(x:80, y:80, width: 240,height: 240)
    let image: UIImage
    var onCropComplete: ((UIImage?) -> Void)?
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .overlay(alignment: .topLeading) {
                    GeometryReader{ geo in
                        CropBoxView(rect: $cropArea)
                            .onAppear {
                                self.imageViewSize = geo.size
                            }
                            .onChange(of: geo.size) {old, new in
                                self.imageViewSize = new
                            }
                    }
                }
                .padding(.top, 8)
            Spacer()
            Button {
                croppedImage = cropImage(image: image, cropRect: cropArea, imageViewSize: imageViewSize)
                onCropComplete?(croppedImage)
                dismiss()
            } label: {
                Image(systemName: "checkmark")
                    .foregroundStyle(.black)
                    .customTextStyle(.normal)
            }
            .frame(maxWidth: .infinity)
          .frame(height: 80)
          .background(Color.mainColor)
          .clipShape(Circle())
          .padding(.bottom,32)
        }
    }
    //IOS카메라는 항상 가로방향으로 저장하고 메타데이터를 통해 세로인 경우 표시.
    private func cropImage(image: UIImage, cropRect: CGRect, imageViewSize: CGSize) -> UIImage? {
        //이미지 방향을 정규화 어떤 방향이든 up방향으로 만들어서하자.
        let normalizedImage: UIImage
        if image.imageOrientation != .up {
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            normalizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        } else {
            normalizedImage = image
        }
        
        //이미지와 뷰의 비율을 정확하게 계산.
        let viewRatio = imageViewSize.width / imageViewSize.height
        let imageRatio = normalizedImage.size.width / normalizedImage.size.height
        
        let scale: CGFloat
        if viewRatio > imageRatio {
            // 이미지가 뷰보다 세로가 길때
            scale = normalizedImage.size.height / imageViewSize.height
        } else {
            // 이미지가 뷰보다 가로가 길때
            scale = normalizedImage.size.width / imageViewSize.width
        }
        
        let scaledCropArea = CGRect(
            x: cropRect.origin.x * scale,
            y: cropRect.origin.y * scale,
            width: cropRect.size.width * scale,
            height: cropRect.size.height * scale
        )
        
        guard let cgImage = normalizedImage.cgImage?.cropping(to: scaledCropArea) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
#Preview {
    ImageEditorView(image: UIImage(named: "logo")!)
}
