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
    case title
    case normal
    case body1
    case large
    case small
    case smallBtn
    var fontSize: CGFloat {
        switch self {
        case .pageTitle: return 17
        case .subheadline: return 15
        case .title: return 22
        case .normal: return 16
        case .body1: return 14
        case .smallBtn: return 14
        case .large: return 23
        case .small: return 11
        }
    }
    
    var weight: Font.Weight {
        switch self {
        case .pageTitle: return .bold
        case .subheadline: return .semibold
        case .body1: return .regular
        case .large: return .bold
        case .small: return .regular
        case .title: return .semibold
        case .normal: return .semibold
        default: return .regular
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
