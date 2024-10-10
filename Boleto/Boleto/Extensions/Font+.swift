//
//  UIFont.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//

import SwiftUI

enum FontName: String {
    case sbfont = "OTSBAggroM"
    case sbboldFont = "OTSBAggroB"
    case ogfont = "OG_Renaissance_Secret-Rg"
    case cafefont = "Cafe24ClassicType-Regular-OTF"
    case partifont = "Partial-Sans-KR"
}

extension Font {
    static func customFont(_ font: FontName, size : CGFloat) -> Font {
        return Font.custom(font.rawValue, size: size)
    }
}
