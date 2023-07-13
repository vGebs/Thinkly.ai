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
    @Binding var currentCourse: CourseDefinition?
    
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
                
                Divider()
                    .foregroundColor(.primary)
                
                if AppState.shared.loading {
                    Spacer()
                    LoadingView()
                    Spacer()
                } else {
                    if viewModel.courses == nil {
                        Spacer()
                        
                        noCourses
                        Spacer()
                        Spacer()
                        Spacer()
                        
                    } else {
                        if viewModel.courses!.count == 0 {
                            Spacer()
                            
                            noCourses
                            Spacer()
                            Spacer()
                            Spacer()
                        } else {
                            ScrollView(showsIndicators: false) {
                                ForEach(viewModel.courses!, id: \.courseFull.courseOverview.courseTitle) { course in
                                    Button(action: {
                                        withAnimation {
                                            self.currentCourse = course
                                        }
                                    }) {
                                        CourseButton(course: course)
                                            .padding(.vertical, 3)
                                    }
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
                        hideKeyboard()
                        addClassPopUpPressed = false
                    }
                }
            }
            
            if AppState.shared.user != nil {
                if AppState.shared.user!.role == "teacher" {
                    SelfLearnCourseDefinitionPopup(addCoursePressed: $addClassPopUpPressed, classListViewModel: viewModel)
//                    CourseDefinitionPopup(classListViewModel: viewModel, addClassPressed: $addClassPopUpPressed)
                        .opacity(addClassPopUpPressed ? 1 : 0)
                } else {
                    AddCourseStudentPopup(classListViewModel: viewModel, addClassPressed: $addClassPopUpPressed)
                        .opacity(addClassPopUpPressed ? 1 : 0)
                }
            }
        }
    }
    
    var header: some View {
        HStack {
            Image(systemName: "newspaper")
                .font(.system(size: 25, weight: .bold, design: .rounded))
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
                    
                    Image(systemName: "brain")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(Color.black)
                    
                    Text("Thinkly.ai")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(Color.buttonPrimary)
                }
                .frame(width: screenWidth, height: screenHeight * 0.85)
            }
        }
    }
    
    var noCourses: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.black)
            
            RoundedRectangle(cornerRadius: 15)
                .stroke(lineWidth: 3)
                .foregroundColor(.buttonPrimary)
            VStack {
                HStack {
                    
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.accent)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    
                    Text("You have no active courses")
                        .foregroundColor(.primary)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.accent)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    
                }
                
                addClassButton_big
            }.padding()
        }
        .padding(.horizontal)
        .frame(height: screenHeight * 0.15)
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
    
    func settingsTapped() {
        print("Settings tapped")
    }
    
    func logoutPressed() {
        AppState.shared.logout()
    }
}

struct CourseButton: View {
    
    var course: CourseDefinition
    @State var showDescription = false
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.black)
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 3)
                .foregroundColor(.buttonPrimary)
            
            VStack {
                HStack {
                    Image(systemName: course.sfSymbol)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    
                    Spacer()
                    
                    Text(course.courseFull.courseOverview.courseTitle)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        if !showDescription {
                            withAnimation {
                                showDescription = true
                            }
                        } else {
                            withAnimation {
                                showDescription = false
                            }
                        }
                    }) {
                        if !showDescription {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.buttonPrimary)
                        } else {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.buttonPrimary)
                        }
                    }
                }.padding(.bottom,3)
                
                if showDescription {
                    Divider()
                    HStack {
                        VStack {
                            Image(systemName: "doc.plaintext")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.accent)
                            Spacer()
                        }
                        
                        Text(course.courseFull.courseOverview.courseDescription)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 16, weight: .light, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
            }.padding()
        }
        .padding(.horizontal)
    }
}
