//
//  Colors.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-11.
//

import SwiftUI

//Primary (Text): #ADD8E6, Button: #3CB371, Accent: #4169E1
//Primary (Text): #FAFAFA, Button: #FF1493, Accent: #7FFF00

extension Color {
    static let primary = Color(hex: "FAFAFA")//EFFFC8
    static let buttonPrimary = Color(hex: "FF1493")//85CB33
    static let accent = Color(hex: "7FFF00")//052F5F
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
    }
}
