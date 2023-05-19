//
//  FeedView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import SwiftUI

struct FeedView: View {
    
    var body: some View {
        ZStack {
            Text("Feed")
                .font(.system(size: 25, weight: .black, design: .rounded))
                .foregroundColor(.buttonPrimary)
        }.frame(width: screenWidth, height: screenHeight)
    }
}
