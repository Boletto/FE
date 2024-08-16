//
//  File.swift
//  Boleto
//
//  Created by Sunho on 8/15/24.
//

import SwiftUI
struct CustomNavigationBarModifier<C,L,R> : ViewModifier where C: View, L: View, R: View {
    let centerView: (() -> C)?
    let leftView: (() -> L)?
    let rightView: (() -> R)?
    init(centerView: ( () -> C)? = nil, leftView: (() -> L)? = nil, rightView: ( () -> R)? = nil) {
        self.centerView = centerView
        self.leftView = leftView
        self.rightView = rightView
    }
    func body(content: Content) -> some View {
        VStack {
            ZStack {
                HStack {
                    self.leftView?()
                    Spacer()
                    self.rightView?()
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .padding(.horizontal,16.0)
//                HStack{
//                    Spacer()
//                    self.centerView?()
//                    Spacer()
//                }
                self.centerView?()
            }
            content
            Spacer()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
