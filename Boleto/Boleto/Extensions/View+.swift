//
//  View+.swift
//  Boleto
//
//  Created by Sunho on 8/16/24.
//

import SwiftUI
extension View {
    func customNavigationBar<C, L> (
        centerView: @escaping (() -> C), leftView: @escaping (() -> L)) -> some View where C: View, L: View {
            modifier(CustomNavigationBarModifier(centerView: centerView, leftView: leftView, rightView: {EmptyView()}))
        }
    func applyBackground(color: Color) -> some View {
        self.modifier(BackgroundModifier(color: color))
    }
    @MainActor
    func captureView(of view: some View, scale: CGFloat = 2, size: CGSize? = nil, completion: @escaping (UIImage?) -> Void) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        if let size = size {
            renderer.proposedSize = .init(size)
        }
        if let image = renderer.uiImage {
               // 알파 채널 제거
               let format = UIGraphicsImageRendererFormat()
               format.opaque = true
               let nonAlphaRenderer = UIGraphicsImageRenderer(size: image.size, format: format)
               let nonAlphaImage = nonAlphaRenderer.image { _ in
                   image.draw(in: CGRect(origin: .zero, size: image.size))
               }
               completion(nonAlphaImage)
           } else {
               completion(nil)
           }
    }
    func snapshot() -> UIImage? {
           let controller = UIHostingController(rootView: self)
           let view = controller.view
           
           let targetSize = controller.view.intrinsicContentSize
           controller.view.bounds = CGRect(origin: .zero, size: targetSize)
           controller.view.backgroundColor = .clear

           let renderer = UIGraphicsImageRenderer(size: targetSize)
           return renderer.image { _ in
               view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
           }
       }
    func customTextStyle(_ style: CustomTextStyle) -> some View {
        self.modifier(TextModifier(textStyle: style))
    }
    func getScreenBounds() -> CGRect{
        return UIScreen.main.bounds
    }
}


struct BackgroundModifier: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        ZStack {
            color.ignoresSafeArea()
            content
        }
    }
}
