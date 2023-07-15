//
//  MainView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-17.
//

import Foundation
import SwiftUI

struct MainView: View {
    
    @State var course: CourseOverview?
    @State private var offset: CGFloat = .zero
    
    var body: some View {
        ZStack{
            CourseList(currentCourse: $course)
                .opacity(course != nil ? Double(min(1, offset / (UIScreen.main.bounds.width / 0.6))) : 1)

            if let _ = course {
                CourseView(course: $course)
                    .frame(width: screenWidth, height: screenHeight * 0.95)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
            }
        }
    }
}

class MainViewState: ObservableObject {
    
    static let shared = MainViewState()
    
    private init() {
        
    }
}
