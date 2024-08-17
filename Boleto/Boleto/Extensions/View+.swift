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
    func applyBackground() -> some View {
        self.modifier(BackgroundModifier())
    }
}

struct BackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.background.ignoresSafeArea()
            content
        }
    }
}
