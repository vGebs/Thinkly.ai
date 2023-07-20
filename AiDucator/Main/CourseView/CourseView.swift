//
//  CourseView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-17.
//

import Foundation
import SwiftUI

struct CourseView: View {
    @Binding var course: CourseOverview?

    @ObservedObject var offsetManager = OffsetManager.shared
    
    var body: some View {
        ZStack {
            wave
            
            mainSwipeView
            
            VStack {
                header
                    .frame(width: screenWidth, height: screenHeight * 0.07)
                Divider()
                    .foregroundColor(.primary)
                
                //Spacer()
                
                if course != nil {
                    HStack {
                        
                        Image(systemName: course!.sfSymbol!)
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundColor(.buttonPrimary)
                            
                        Text(course!.courseTitle)
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .frame(width: screenWidth)
                    //.padding(.bottom, screenHeight * 0.065)
                    
                    Divider()
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
        }
    }
    
    var header: some View {
        HStack {
            
            title
                
            Spacer()
            
            
            Button(action: {
                withAnimation {
                    course = nil
                    DispatchQueue.main.async {
                        withAnimation {
                            self.offsetManager.offset = screenWidth * 2
                        }
                    }
                }
            }) {
                Image(systemName: "house.fill")
                    .font(.system(size: 22, weight: .regular, design: .rounded))
                    .foregroundColor(.buttonPrimary)
            }.padding(.trailing)
            
            Menu {
                Button("Settings", action: settingsTapped)
                Button("Logout", action: logoutPressed)
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 22, weight: .regular, design: .rounded))
                    .foregroundColor(.buttonPrimary)
            }
        }
        .padding(.horizontal, 5)
        .padding(.top)
    }
    
    var title: some View {
        ZStack {
            HStack {
                Image(systemName: "note.text")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                    .padding(.leading)
                
                Text("Notes")
                    .foregroundColor(.primary)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                Spacer()
            }
            .opacity(self.offsetManager.offset >= 0 && self.offsetManager.offset < (screenWidth - screenWidth * 0.5) ? 1 : 0)
            
            HStack {
                Image(systemName: "tray")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                    .padding(.leading)
                
                Text("Assignments")
                    .foregroundColor(.primary)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                Spacer()
            }
            .opacity(self.offsetManager.offset >= screenWidth * 0.5 && self.offsetManager.offset < ((screenWidth * 2) - screenWidth * 0.5) ? 1 : 0)
            
            HStack {
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                    .padding(.leading)
                
                Text("Feed")
                    .foregroundColor(.primary)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                Spacer()
            }
            .opacity(self.offsetManager.offset >= ((screenWidth * 2) - screenWidth * 0.5) && self.offsetManager.offset < ((screenWidth * 3) - screenWidth * 0.5) ? 1 : 0)
            
            HStack {
                Image(systemName: "list.bullet.clipboard")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                    .padding(.leading)
                
                Text("Quizzes")
                    .foregroundColor(.primary)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                Spacer()
            }
            .opacity(self.offsetManager.offset >= ((screenWidth * 3) - screenWidth * 0.5) && self.offsetManager.offset < ((screenWidth * 4) - screenWidth * 0.5) ? 1 : 0)
            
            HStack {
                Image(systemName: "chart.dots.scatter")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                    .padding(.leading)
                
                Text("Grades")
                    .foregroundColor(.primary)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                Spacer()
            }
            .opacity(self.offsetManager.offset >= ((screenWidth * 4) - screenWidth * 0.5) && self.offsetManager.offset < ((screenWidth * 5) - screenWidth * 0.5) ? 1 : 0)
        }
    }
    
    func settingsTapped() {
        print("Settings tapped")
    }
    
    func logoutPressed() {
        AppState.shared.logout()
    }
    
    @State private var phase = AnimatableData(phase: 0)
    @State private var phase1 = AnimatableData(phase: 45)
    @State private var phase2 = AnimatableData(phase: 90)
    
    var mainSwipeView: some View {
        
        GeometryReader { proxy in
            let rect = proxy.frame(in: .global)
            
            Pager(tabs: tabs, rect: rect, offset: $offsetManager.offset) {
                
                HStack(spacing: 0){
                    NotesView(viewModel: NotesViewModel(courseDef: course))
                    AssignmentsView()
                    FeedView()
                    QuizView()
                    GradesView()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .overlay(
            NavBar(offset: $offsetManager.offset)
                .padding(.bottom, screenHeight * 0.035),
            alignment: .bottom
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    
    var wave: some View {
        ZStack {
            VStack {
                Spacer()
                SineWave(frequency: 0.3, amplitude: 0.035, phase: phase)
                    .fill(Color.accent)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                            phase.phase += 1
                        }
                    }
            }
            
            VStack {
                Spacer()
                SineWave(frequency: 0.5, amplitude: 0.03, phase: phase1)
                    .fill(Color.buttonPrimary)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                            phase1.phase += 1
                        }
                    }
            }.offset(y: 130)
            
            ZStack {
                VStack {
                    Spacer()
                    SineWave(frequency: 0.5, amplitude: 0.025, phase: phase2)
                        .fill(Color.primary)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                                phase2.phase += 1
                            }
                        }
                }.offset(y: 200)
            }
        }
    }
}

let tabs = ["Notes", "Assignments", "Feed", "Quizzes", "Grades"]
