//
//  GradesView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import SwiftUI

struct GradesView: View {
    
    var body: some View {
        ZStack {
            Text("Grades")
                .font(.system(size: 25, weight: .black, design: .rounded))
                .foregroundColor(.buttonPrimary)
        }.frame(width: screenWidth, height: screenHeight)
    }
}
