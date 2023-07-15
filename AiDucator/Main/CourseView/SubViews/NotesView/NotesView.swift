//
//  NotesView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import SwiftUI

struct NotesView: View {
    
    @ObservedObject var viewModel: NotesViewModel
    @State var selectedVersion = 0
    
    var body: some View {
        
        VStack {
            Spacer()
            ScrollView {
                
                if viewModel.curriculums[0].units.count > 0{
                    warnings
                    
                    Divider()
                    
                    if viewModel.errorOccurred == selectedVersion {
                        errorWarning
                        continueGeneratingButton
                    }
                    
                    if viewModel.stopped.contains(selectedVersion) {
                        continueGeneratingButton
                        //resetButton
                    }
                    
                    if viewModel.doneGenerating[selectedVersion] {
                    
                        submitUnitsButton
                        
                        HStack {
                            regenerateVersionButton
                            
                            
                            if viewModel.curriculums.count <= 2 {
                                Spacer()
                                generateNewVersionButton
                            }
                        }
                        
                        trashVersionButton
                        
                    } else if !viewModel.doneGenerating[selectedVersion] && viewModel.loading {
                        LoadingView()
                            .padding(.vertical)
                        stopGeneratingButton
                    }
                }
                
                if viewModel.curriculums.count > 1 {
                    versionSelectButton
                }
                //                    if viewModel.weeklyContent.count > 0 {
                //                        ForEach(viewModel.weeklyContent) { content in
                //                            MyUnitsDropDown(thisWeeksContent: content)
                //                                .padding(.horizontal, 5)
                //                        }
                //                        .padding(.top, screenHeight * 0.01)
                //                    }
                
                
                if viewModel.curriculums[selectedVersion].units.count > 0 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.black)
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 3)
                            .foregroundColor(.buttonPrimary)
                        
                        VStack {
                            ForEach(viewModel.curriculums[selectedVersion].units.indices, id: \.self) { index in
                                WeeklyTopicDropDown(topic: $viewModel.curriculums[selectedVersion].units[index])
                                    .padding(index == viewModel.curriculums[selectedVersion].units.count - 1 ? .bottom : [])
                                    .padding(index == 0 ? .top : [])
                                
                                if index != viewModel.curriculums[selectedVersion].units.count - 1 {
                                    Divider()
                                }
                            }
                            .padding(.top, screenHeight * 0.01)
                        }
                    }
                    .padding(.horizontal)
                }
                
                if let user = AppState.shared.user {
                    if user.role == "teacher" {
                        
                        if viewModel.curriculums[0].units.count == 0 {
                            
                            preWarning
                            if viewModel.errorOccurred == selectedVersion {
                                errorWarning
                            }
                            
                            if viewModel.loading {
                                LoadingView()
                                    .padding(.bottom)
                                stopGeneratingButton
                            } else {
                                HStack {
                                    Spacer()
                                    generatePreliminaryCurriculumButton
                                    Spacer()
                                }.padding(.horizontal)
                            }
                        }
                        
                    }
                }
                
                Spacer().padding(.bottom, screenHeight * 0.13)
            }
            .frame(width: screenWidth, height: screenHeight * (1 - 0.11))
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: screenWidth, height: screenHeight)
    }
    
    var stopGeneratingButton: some View {
        Button(action: {
            viewModel.stopGenerating(selectedVersion)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.black)
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                
                HStack {
                    Spacer()
                    Image(systemName: "stop.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    Text("Stop Generating")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                }.padding()
            }
        }.padding(.horizontal)
    }
    
    var resetButton: some View {
        Button(action: {
            withAnimation {
                viewModel.resetUnits(selectedVersion)
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.black)
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                
                HStack {
                    Spacer()
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    Text("Reset units")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                }.padding()
            }
        }.padding(.horizontal)
    }
    
    var submitUnitsButton: some View {
        Button(action: {
            viewModel.submitUnits(selectedVersion)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.black)
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                
                HStack {
                    Spacer()
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    Text("Submit V-\(selectedVersion + 1)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                }.padding()
            }
        }.padding(.horizontal)
    }
    
    var regenerateVersionButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.black)
            RoundedRectangle(cornerRadius: 15)
                .stroke(lineWidth: 3)
                .foregroundColor(.buttonPrimary)
            
            Button(action: {
                viewModel.regenerateVersion(selectedVersion)
            }) {
                HStack {
                    Image(systemName: "terminal")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    Text("Regenerate V-\(selectedVersion + 1)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }.padding()
            }
        }.padding(.horizontal)
    }
    
    var generateNewVersionButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.black)
            RoundedRectangle(cornerRadius: 15)
                .stroke(lineWidth: 3)
                .foregroundColor(.buttonPrimary)
            
            Button(action: {
                viewModel.generateNewCurriculum(viewModel.curriculums.count)
            }) {
                HStack {
                    Image(systemName: "terminal")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    Text("Generate V-\(viewModel.curriculums.count + 1)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }.padding()
            }
        }.padding(.trailing)
    }
    
    var trashVersionButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.black)
            RoundedRectangle(cornerRadius: 15)
                .stroke(lineWidth: 3)
                .foregroundColor(.buttonPrimary)
            
            Button(action: {
                withAnimation {
                    if selectedVersion != 0 {
                        selectedVersion -= 1
                    }
                    viewModel.trashVersion(number: selectedVersion)
                }
            }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    Text("Trash V-\(selectedVersion + 1)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }.padding()
            }
        }.padding(.horizontal)
    }
    
    var versionSelectButton: some View {
        HStack {
            ForEach(viewModel.curriculums.indices, id: \.self) { index in
                Button(action: {
                    withAnimation {
                        selectedVersion = index
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.black)
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 3)
                            .foregroundColor(.buttonPrimary)
                        
                        HStack {
                            Spacer()
                            if selectedVersion == index {
                                Image(systemName: "smallcircle.filled.circle.fill")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.accent)
                            }
                            Text("V-\(index + 1)")
                                .font(.system(size: 16, weight: selectedVersion == index ? .bold : .regular, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                        }.padding()
                    }
                }
            }
        }.padding(.horizontal)
    }
    
    var errorWarning: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.black)
            RoundedRectangle(cornerRadius: 15)
                .stroke(lineWidth: 3)
                .foregroundColor(.accent)
            
            HStack {
                Spacer()
                
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                
                Text("An error occurred")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }.padding()
        }.padding(.horizontal)
    }
    
    var continueGeneratingButton: some View {
        Button(action: {
            withAnimation {
                viewModel.continueGeneratingCurriculum(selectedVersion: selectedVersion)
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.black)
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                
                HStack {
                    Image(systemName: "arrow.uturn.right.square")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    
                    Text("Continue Generating")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }.padding()
            }
        }.padding(.horizontal)
    }
    
    var preWarning: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.black)
            RoundedRectangle(cornerRadius: 15)
                .stroke(lineWidth: 3)
                .foregroundColor(.accent)
            VStack {
                
                HStack {
                    VStack {
                        Image(systemName: "lock.open.trianglebadge.exclamationmark")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.accent)
                        Spacer()
                    }
                    
                    Text("Press 'Generate' to create some initial units for your course.")
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
            }.padding()
        }.padding()
    }
    
    var warnings: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.black)
            RoundedRectangle(cornerRadius: 15)
                .stroke(lineWidth: 3)
                .foregroundColor(.accent)
            VStack {
                
                HStack {
                    VStack {
                        Image(systemName: "lock.open.trianglebadge.exclamationmark")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.accent)
                        Spacer()
                    }
                    
                    Text("Press 'Regenerate' to discover alternative appropriate units.")
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }.padding(.bottom)
                
                HStack {
                    VStack {
                        Image(systemName: "lock.open.trianglebadge.exclamationmark")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.accent)
                        Spacer()
                    }
                    
                    Text("You can create three curriculum versions before selecting your favorite.")
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }.padding(.bottom)
                
                HStack {
                    VStack {
                        Image(systemName: "lock.open.trianglebadge.exclamationmark")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.accent)
                        Spacer()
                    }
                    
                    Text("When you have chosen your version, press submit to continue.")
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
            }.padding()
        }.padding()
    }
    
    var generatePreliminaryCurriculumButton: some View {
        Button(action: {
            withAnimation {
                viewModel.errorOccurred = -1
                viewModel.generateNewCurriculum(selectedVersion)
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.black)
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                HStack {
                    Image(systemName: "terminal")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                        .padding(.leading, 5)
                    Text("Generate")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                }
                .padding()
            }
            .padding(.top, 5)
        }
    }
    
//    var generateOutline: some View {
//        Button(action: {
//            withAnimation {
//
//            }
//        }) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 20)
//                    .foregroundColor(.black)
//                RoundedRectangle(cornerRadius: 20)
//                    .stroke(lineWidth: 3)
//                    .foregroundColor(.buttonPrimary)
//                HStack {
//                    Image(systemName: "terminal")
//                        .font(.system(size: 17, weight: .bold, design: .rounded))
//                        .foregroundColor(.accent)
//                        .padding(.leading, 5)
//                    Text("Generate Week: \(viewModel.weeklyContent.count + 1)")
//                        .font(.system(size: 16, weight: .bold, design: .rounded))
//                        .foregroundColor(.primary)
//                    Spacer()
//                }
//                .padding()
//            }
//            .padding(.top, 5)
//        }
//    }
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
