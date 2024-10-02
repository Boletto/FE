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
    
    var fontWeight: String {
        let familyName = "Pretendard"
        switch self {
        case .pageTitle: 
            return "\(familyName)-Bold"
        case .subheadline: 
            return "\(familyName)-SemiBold"
        case .body1:
            return "\(familyName)-Regular"
           
        case .large: 
            return "\(familyName)-Bold"
        case .small: 
            return "\(familyName)-Regular"
        case .title:
            return "\(familyName)-SemiBold"
        case .normal:
            return "\(familyName)-SemiBold"
        default: 
            return "\(familyName)-Regular"
        }
    }
}
struct TextModifier: ViewModifier {
    let textStyle: CustomTextStyle
    func body(content: Content) -> some View {
        content
            .font(.custom(textStyle.fontWeight, size: textStyle.fontSize))
    }
}
