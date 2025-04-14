//
//  View+.swift
//  Boleto
//
//  Created by Sunho on 8/16/24.
//

import SwiftUI
enum CaptureError: Error {
    case renderingFailed
    case imageProcessingFailed
}
extension View {
    func customNavigationBar<C, L> (
        centerView: @escaping (() -> C), leftView: @escaping (() -> L)) -> some View where C: View, L: View {
            modifier(CustomNavigationBarModifier(centerView: centerView, leftView: leftView, rightView: {EmptyView()}))
        }
    func applyBackground(color: Color) -> some View {
        self.modifier(BackgroundModifier(color: color))
    }
    @MainActor
    func captureView(of view: some View, scale: CGFloat = 2) async throws -> UIImage {
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        guard let image = renderer.uiImage else {throw CaptureError.renderingFailed}
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        let nonAlphaRenderer = UIGraphicsImageRenderer(size: image.size, format: format)
        let nonAlphaImage = nonAlphaRenderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        return nonAlphaImage
    }
    @MainActor
    func snapshotView() throws  -> UIImage{
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first(where: { $0.isKeyWindow }) else {
            throw CaptureError.imageProcessingFailed
         }
        return window.snapshot()!
    }
    @MainActor
    func captureSpecificArea(frame: CGRect) async throws -> UIImage {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) else {
            throw CaptureError.imageProcessingFailed
        }
        
        // 전체 화면 스냅샷
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: window.bounds.size, format: format)
          let screenshotImage = renderer.image { ctx in
              window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
          }
        // 스케일 고려한 영역 계산
        let scale = UIScreen.main.scale
        let scaledFrame = CGRect(
            x: frame.origin.x * scale,
            y: frame.origin.y * scale,
            width: frame.width * scale,
            height: frame.height * scale
        )
        
        // 지정 영역만 크롭
        guard let cgImage = screenshotImage.cgImage?.cropping(to: scaledFrame) else {
            throw CaptureError.imageProcessingFailed
        }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
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
