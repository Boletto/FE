//
//  SplashView.swift
//  Boleto
//
//  Created by Sunho on 12/7/24.
//

import SwiftUI
import UIKit
import Lottie


struct LottieView: UIViewRepresentable {
    typealias UIviewType = UIView
    var fileName: String
    var onEnd: () -> Void
    func makeUIView(context: UIViewRepresentableContext<LottieView>) ->  UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(fileName)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 1.4
        animationView.play {finished in
            if finished {
                onEnd()
            }
        }
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                  animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                  animationView.topAnchor.constraint(equalTo: view.topAnchor),
                  animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
        return view
    }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        
    }
    
}
