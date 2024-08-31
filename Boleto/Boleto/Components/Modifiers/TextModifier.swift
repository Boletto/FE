//
//  TextModifier.swift
//  Boleto
//
//  Created by Sunho on 8/31/24.
//

import SwiftUI
enum CustomTextStyle {
    case pageTitle
    case subheadline
    case body1
    case body2
    case large
    case small
    var fontSize: CGFloat {
        switch self {
        case .pageTitle: return 17
        case .subheadline: return 15
        case .body1: return 17
        case .body2: return 15
        case .large: return 23
        case .small: return 11
        }
    }
    
//    var lineSpacing: CGFloat {
//        switch self {
//        case .pageTitle: return 17
//        case .subheadline: return 15
//        case .body1: return 24
//        case .body2: return 22
//        case .large: return 27
//        case .small: return 16
//        }
//    }
    var weight: Font.Weight {
        switch self {
        case .pageTitle: return .bold
        case .subheadline: return .semibold
        case .body1: return .regular
        case .body2: return .regular
        case .large: return .bold
        case .small: return .semibold
        }
    }
}
struct TextModifier: ViewModifier {
    let textStyle: CustomTextStyle
    func body(content: Content) -> some View {
        content
            .font(.system(size: textStyle.fontSize, weight: textStyle.weight))
//            .lineSpacing(textStyle.lineSpacing)
    }
}
