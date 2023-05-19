//
//  NotesView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import SwiftUI

struct NotesView: View {
    
    
    var body: some View {
        ZStack {
            Text("Notes")
                .font(.system(size: 25, weight: .black, design: .rounded))
                .foregroundColor(.buttonPrimary)
        }.frame(width: screenWidth, height: screenHeight)
    }
}
