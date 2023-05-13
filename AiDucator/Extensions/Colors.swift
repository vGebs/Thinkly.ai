//
//  Colors.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-11.
//

import SwiftUI

extension Color {
    static let primary = Color(hex: "EFFFC8")//ColorScheme 1: Color(hex: "F40B73")
    static let accent = Color(hex: "052F5F")//ColorScheme 1: Color(hex: "F4170B")
    static let buttonPrimary = Color(hex: "85CB33")//ColorScheme 1: Color(hex: "F40BE8")
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
