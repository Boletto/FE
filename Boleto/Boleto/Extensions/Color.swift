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
//    static let customSkyBlue = Color("CustomSkyBlue")
    init(hex: String) {
           let scanner = Scanner(string: hex)
           scanner.currentIndex = scanner.string.startIndex
           
           var rgbValue: UInt64 = 0
           scanner.scanHexInt64(&rgbValue)
           
           let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
           let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
           let blue = Double(rgbValue & 0x0000FF) / 255.0
           
           self.init(red: red, green: green, blue: blue)
       }
}
