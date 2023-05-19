//
//  QuizView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import SwiftUI

struct QuizView: View {
    
    var body: some View {
        ZStack {
            Text("Quizzes")
                .font(.system(size: 25, weight: .black, design: .rounded))
                .foregroundColor(.buttonPrimary)
        }.frame(width: screenWidth, height: screenHeight)
    }
}
