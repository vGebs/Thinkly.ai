//
//  MainView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import SwiftUI
import Combine


//ok so we need to make this view such that it can be used by both students and the teachers
// They will see the same view but will have different options
// The student can add a class based on the classID
// The teacher can create a class and can fetch the access code for their students
// Once the student enters the class, the teacher has the accept the student before joining

//Ok, we have all of the fetching logic done for the classes
// now we need to integrate that into the UI
//
// I want to make a popup instead of a sheet and then submit the class
// The class will then be listed on the teachers courses


struct CourseList: View {

    @StateObject var viewModel = CourseListViewModel()
    @Binding var currentCourse: Course?
    
    @State var addClassPopUpPressed = false
    
    @State private var phase = AnimatableData(phase: 0)
    @State private var phase1 = AnimatableData(phase: 45)
    @State private var phase2 = AnimatableData(phase: 90)
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            wave
            
            VStack {
                header
                    .frame(width: screenWidth, height: screenHeight * 0.07)
                
                if AppState.shared.loading {
                    Spacer()
                    LoadingView()
                    Spacer()
                } else {
                    if viewModel.courses == nil {
                        Spacer()
                        
                        noCourses
                        
                        Spacer()
                        
                    } else {
                        if viewModel.courses!.count == 0 {
                            Spacer()
                            
                            noCourses
                            
                            Spacer()
                        } else {
                            ScrollView(showsIndicators: false) {
                                ForEach(viewModel.courses!, id: \.title) { course in
                                    Button(action: {
                                        withAnimation {
                                            self.currentCourse = course
                                        }
                                    }) {
                                        CourseButton(course: course)
                                            .padding(.vertical, 3)
                                    }
                                    .frame(width: screenWidth, height: screenHeight * 0.085)
                                }
                                .padding(.top, 10)
                            }
                        }
                    }
                }
            }
            .blur(radius: addClassPopUpPressed ? 10 : 0)
            .disabled(addClassPopUpPressed)
            .onTapGesture {
                if addClassPopUpPressed {
                    withAnimation {
                        addClassPopUpPressed = false
                    }
                }
            }
            
            if addClassPopUpPressed {
                AddCoursePopUp(classListViewModel: viewModel, addClassPressed: $addClassPopUpPressed)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .trailing)))
            }
        }
    }
    
    var addClassButton_big: some View {
        Button(action: {
            withAnimation {
                addClassPopUpPressed = true
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 2)
                    .foregroundColor(.accent)
                HStack{
                    Image(systemName: "plus.app")
                        .frame(width: 30, height: 30)
                        .foregroundColor(.buttonPrimary)
                        .padding(.leading)
                    Text("Add Class")
                        .font(.title2)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
        }.frame(width: screenWidth * 0.9, height: screenHeight / 20)
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
                
                VStack {
                    Spacer()
                    
                    Text("Thinkly.ai")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .frame(width: 110, height: 40)
                        .foregroundColor(Color.buttonPrimary)
                }
            }
        }
    }
    
    var noCourses: some View {
        VStack {
            HStack {
                
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.accent)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                
                Text("You have no active courses")
                    .foregroundColor(.primary)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.accent)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                
            }
            
            addClassButton_big
        }
    }
    
    var header: some View {
        HStack {
            Image(systemName: "newspaper")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.accent)
                .padding(.leading)
            
            Text("Courses")
                .foregroundColor(.primary)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                
            Spacer()
            
            if viewModel.courses != nil {
                if viewModel.courses!.count != 0 {
                    Button(action: {
                        withAnimation {
                            addClassPopUpPressed = true
                        }
                    }) {
                        Image(systemName: "plus.app")
                            .font(.system(size: 22, weight: .regular, design: .rounded))
                            .foregroundColor(.buttonPrimary)
                    }.padding(.trailing)
                }
            }
            
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
    
    func settingsTapped() {
        print("Settings tapped")
    }
    
    func logoutPressed() {
        AppState.shared.logout()
    }
}

struct CourseButton: View {
    
    var course: Course
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.black)
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 3)
                .foregroundColor(.buttonPrimary)
            
            HStack {
                ZStack {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            Image(systemName: course.sfSymbol)
                                .foregroundColor(.accent)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .padding(.leading)
                                .padding(.vertical)
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
                .padding(.leading, 9)
                .padding(.trailing, 3)
                .frame(width: screenHeight / 22, height: screenHeight / 22)
                
                VStack {
                    HStack {
                        Text(course.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text(course.description)
                            .font(.system(size: 16, weight: .light, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }.padding(.leading)
            }
        }
        .padding(.horizontal)
    }
}
