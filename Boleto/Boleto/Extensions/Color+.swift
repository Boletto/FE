//
//  Color.swift
//  Boleto
//
//  Created by Sunho on 8/14/24.
//

import SwiftUI

extension Color {
    static let customGray1 = Color("Gray1")
    static let mainColor = Color("MainColor")
    static let background = Color("CustomBackground")
    static let modalColor = Color("Modal")
    static let kakaoColor = Color("Kakao")
    static let red1Color = Color("Red1")
    static let red2Color = Color("Red2")
    static let gray5Color = Color("Gray5")
//    static let customSkyBlue = Color("CustomSkyBlue")
    init(hex: String) {
            var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            
            // Remove the '#' if it's there
            if hexSanitized.hasPrefix("#") {
                hexSanitized.remove(at: hexSanitized.startIndex)
            }
            
            // Ensure that the string is 6 characters long
            guard hexSanitized.count == 6 else {
                // Return a default color if the hex code is invalid
                self = .clear
                return
            }
            
            var rgbValue: UInt64 = 0
            Scanner(string: hexSanitized).scanHexInt64(&rgbValue)
            
            let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = Double(rgbValue & 0x0000FF) / 255.0
            
            self.init(red: red, green: green, blue: blue)
        }
}
