//
//  NotesView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import SwiftUI

struct NotesView: View {
    
    @ObservedObject var viewModel: NotesViewModel
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ScrollView {
                    
                    ForEach(viewModel.weeklyContent) { content in
                        MyUnitsDropDown(thisWeeksContent: content)
                            .padding(.horizontal, 5)
                    }
                    .padding(.top, screenHeight * 0.01)
                    
                    if let user = AppState.shared.user {
                        if user.role == "teacher" {
                            
                            Divider()
                            
                            HStack {
                                Spacer()
                                generateOutline
                                Spacer()
                            }
                            
                            
                        }
                    }
                    
                    Spacer().padding(.bottom, screenHeight * 0.13)
                }
                .frame(width: screenWidth, height: screenHeight * (1 - 0.11))
            }
//            .disabled(showAutoGenPopup)
//            .blur(radius: showAutoGenPopup ? 10 : 0)
//            .onTapGesture {
//                hideKeyboard()
//                withAnimation {
//                    showAutoGenPopup = false
//                }
//            }
//            if showAutoGenPopup {
//                AutoGenPopup()
//                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
//            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: screenWidth, height: screenHeight)
    }
    
    var generateOutline: some View {
        Button(action: {
            withAnimation {
                
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.black)
                RoundedRectangle(cornerRadius: 20)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                HStack {
                    Image(systemName: "terminal")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                        .padding(.leading, 5)
                    Text("Generate Week: \(viewModel.weeklyContent.count + 1)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding()
            }
            .padding(.top, 5)
        }
    }
}


import SwiftUI

struct AutoGenPopup: View {
    @State var courseName: String = ""
    @State var courseDurationInWeeks: Double = 15
    @State var classesPerWeek: Double = 3
    @State var classLengthInHours: Double = 1
    @State var studyHoursPerWeek: Double = 10
    @State var gradeLevel: String = ""
    @State var textBookReferences: String = ""
    @State var learningObjectives: String = ""
    @State var preRequisites: String = ""
    @State var topicPreferences: String = ""

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.black)
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 4)
                .foregroundColor(.buttonPrimary)
            
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    Text("Auto-Gen Course Sections")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    VStack {
                        TextFieldView__(title: "Course Name", text: $courseName)
                        NumberInputView(title: "Course Duration in Weeks", value: $courseDurationInWeeks, range: 1...52)
                        NumberInputView(title: "Classes per Week", value: $classesPerWeek, range: 1...7)
                        NumberInputView(title: "Class Length in Hours", value: $classLengthInHours, range: 1...5)
                        NumberInputView(title: "Study Hours per Week", value: $studyHoursPerWeek, range: 1...40)
                        TextFieldView__(title: "Grade Level", text: $gradeLevel)
                    }

                    VStack {
                        TextFieldView__(title: "Textbook References", text: $textBookReferences)
                        TextFieldView__(title: "Learning Objectives", text: $learningObjectives)
                    }

                    VStack {
                        TextFieldView__(title: "Prerequisites", text: $preRequisites)
                        TextFieldView__(title: "Topic Preferences", text: $topicPreferences)
                    }
                    
                    Button(action: submitForm) {
                        Text("Submit")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }.frame(width: screenWidth * 0.9, height: screenHeight * 0.75)
    }

    func submitForm() {
        // Handle form submission here
    }
}

struct TextFieldView__: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            TextField(title, text: $text)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
        }
    }
}

struct NumberInputView: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            HStack {
                Slider(value: $value, in: range)
                Text("\(Int(value))")
                    .frame(width: 50)
            }
            .padding(.vertical)
        }
    }
}
