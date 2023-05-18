//
//  CourseView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-17.
//

import Foundation
import SwiftUI

struct CourseView: View {
    @Binding var course: Course?

    @State var offset: CGFloat = screenWidth * 2
    
    var body: some View {
        ZStack {
            mainSwipeView
        }
    }
    
    var mainSwipeView: some View {
        GeometryReader { proxy in
            let rect = proxy.frame(in: .global)
            
            Pager(tabs: tabs, rect: rect, offset: $offset) {
                
                HStack(spacing: 0){
                    NotesView()
                    AssignmentsView()
                    FeedView()
                    QuizView()
                    GradesView()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .overlay(
            NavBar(offset: $offset)
                .padding(.bottom, screenHeight * 0.035),
            alignment: .bottom
        )
        .preferredColorScheme(.dark)
        .edgesIgnoringSafeArea(.all)
    }
}

let tabs = ["Notes", "Assignments", "Feed", "Quizes", "Grades"]
