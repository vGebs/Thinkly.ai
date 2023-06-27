//
//  SelfLearnCourseDefinitionPopup.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-06-25.
//

import SwiftUI

struct SelfLearnCourseDefinitionPopup: View {
    @Binding var addCoursePressed: Bool
    @StateObject var viewModel = SelfLearnCourseDefinitionViewModel()
    @ObservedObject var classListViewModel: CourseListViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.black)
            
            VStack {
                ScrollView {
                    header
                    userPrompt
                    
                    if viewModel.userPrompt.count > 15 && viewModel.learningObjectives.count == 0 {
                        if viewModel.loading {
                            LoadingView()
                        } else {
                            generateLearningObjectivesButton
                        }
                    }
                    
                    
                    if viewModel.learningObjectives.count > 0 {
                        Divider()
                        learningObjectivesView
                        
                        Divider()
                        
                        if viewModel.loading {
                            LoadingView()
                        } else {
                            generateCourseOverviewButton
                        }
                        
                        if viewModel.courseOverviewSuggestions.count > 0 {
                            Divider()
                            courseOverviewView
                        }
                    }
                    
                    Divider()
                    addCourseButton
                        .padding(.bottom)
                }
            }
            
            RoundedRectangle(cornerRadius: 25)
                .stroke(lineWidth: 4)
                .foregroundColor(.buttonPrimary)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .frame(width: screenWidth * 0.9, height: screenHeight / 1.4)
    }
    
    var header: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            addCoursePressed = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.buttonPrimary)
                    }
                    .padding(.top)
                    .padding(.trailing)
                }
                Spacer()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Text("Create Course")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top)
                    Spacer()
                }
                Spacer()
            }
        }
    }
    
    var userPrompt: some View {
        VStack {
            HStack {
                Image(systemName: "questionmark.square")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                
                Text("What would you like to learn about?")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                
                if viewModel.learningObjectives.count == 0 {
                    GrowingTextView(text: $viewModel.userPrompt)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.all)
                } else {
                    Text(viewModel.userPrompt)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                        .padding()
                }
            }
        }.padding()
    }
    
    var generateLearningObjectivesButton: some View {
        VStack {
            Button(action: {
                viewModel.generateLearningObjectives()
            }) {
                HStack {
                    Image(systemName: "terminal")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    Text("Generate Learning Objectives")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .padding()
                .background(content: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.black)
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 4)
                            .foregroundColor(.buttonPrimary)
                    }
                })
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
    
    var learningObjectiveTitleView: some View {
        HStack {
            Image(systemName: "lightbulb")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.accent)
            
            Text("Learning Objectives")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
        }.padding(.horizontal)
    }
    
    var learningObjectivesView: some View {
        VStack {
            
            learningObjectiveTitleView
            
            ForEach(viewModel.learningObjectives.indices, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.buttonPrimary)
                        
                    VStack {
                        HStack {
                            Image(systemName: "lightbulb")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.accent)
                            Text("Objective")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if viewModel.courseOverviewSuggestions.count == 0 {
                                Button(action: {
                                    withAnimation {
                                        var temp = viewModel.learningObjectives
                                        temp.remove(at: index)
                                        viewModel.learningObjectives = temp
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.buttonPrimary)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                            }
                        }
                        HStack {
                            Text(viewModel.learningObjectives[index].objectiveTitle)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }.padding(.bottom)
                        
                        HStack {
                            Image(systemName: "doc.plaintext")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.accent)
                            Text("Objective Description")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text(viewModel.learningObjectives[index].objectiveDescription)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                    .padding()
                }.padding(.horizontal)
            }
            if viewModel.courseOverviewSuggestions.count == 0 {
                HStack {
                    regenerateLearningObjectivesButton
                    removeAllLearningObjectivesButton
                }
            }
        }
    }
    
    var removeAllLearningObjectivesButton: some View {
        
        Button(action: {
            withAnimation {
                viewModel.learningObjectives = []
            }
        }) {
            ZStack {
                
                Image(systemName: "trash")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .padding()
                    .background(content: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 4)
                                .foregroundColor(.buttonPrimary)
                        }
                    })
                    .foregroundColor(.accent)
                    .cornerRadius(8)
            }
        }
    }
    
    var regenerateLearningObjectivesButton: some View {
        VStack {
            if viewModel.learningObjectives.count > 0 {
                Button(action: {
                    withAnimation {
                        withAnimation {
                            viewModel.learningObjectives = []
                            viewModel.generateLearningObjectives()
                        }
                    }
                }) {
                    HStack {
                        ZStack {
                            Image(systemName: "square")
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                                .foregroundColor(.accent)
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.accent)
                        }
                        
                        Text("Regenerate")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .padding()
                    .background(content: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 4)
                                .foregroundColor(.buttonPrimary)
                        }
                    })
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    var generateCourseOverviewButton: some View {
        VStack {
            if viewModel.learningObjectives.count > 0 {
                Button(action: {
                    viewModel.getCourseTitleSuggestion()
                }) {
                    HStack {
                        Image(systemName: "terminal")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.accent)
                        Text("Generate Course Title")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .padding()
                    .background(content: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 4)
                                .foregroundColor(.buttonPrimary)
                        }
                    })
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    var courseOverViewTitleView: some View {
        HStack {
            Image(systemName: "highlighter")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.accent)
            
            Text("Course Titles")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
        }.padding(.horizontal)
    }
    
    var courseOverviewView: some View {
        VStack {
            courseOverViewTitleView
            ForEach(viewModel.courseOverviewSuggestions.indices, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.buttonPrimary)
                        
                    VStack {
                        HStack {
                            Image(systemName: "highlighter")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.accent)
                            Text("Course Name")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            
                            Image(systemName: viewModel.selectedCourseIndex == index ? "checkmark.square" : "square")
                                .foregroundColor(.buttonPrimary)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        HStack {
                            Text(viewModel.courseOverviewSuggestions[index].courseTitle)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }.padding(.bottom)
                        
                        HStack {
                            Image(systemName: "doc.plaintext")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.accent)
                            Text("Course Description")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text(viewModel.courseOverviewSuggestions[index].courseDescription)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }.padding(.bottom)
                    }
                    .padding()
                }
                .padding(.horizontal)
                .onTapGesture {
                    withAnimation {
                        if viewModel.selectedCourseIndex == index {
                            viewModel.selectedCourseIndex = -1
                        } else {
                            viewModel.selectedCourseIndex = index
                        }
                    }
                }
            }
            
            
            HStack {
                regenerateCourseOverviewButton
                
                removeAllCourseOverView
            }
            
        }
    }
    
    var removeAllCourseOverView: some View {
        Button(action: {
            withAnimation {
                viewModel.courseOverviewSuggestions = []
            }
        }) {
            ZStack {
                
                Image(systemName: "trash")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .padding()
                    .background(content: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 4)
                                .foregroundColor(.buttonPrimary)
                        }
                    })
                    .foregroundColor(.accent)
                    .cornerRadius(8)
            }
        }
    }
    
    var regenerateCourseOverviewButton: some View {
        VStack {
            if viewModel.courseOverviewSuggestions.count > 0 {
                Button(action: {
                    withAnimation {
                        viewModel.courseOverviewSuggestions = []
                        viewModel.getCourseTitleSuggestion()
                    }
                }) {
                    HStack {
                        ZStack {
                            Image(systemName: "square")
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                                .foregroundColor(.accent)
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.accent)
                        }
                        
                        Text("Regenerate")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .padding()
                    .background(content: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 4)
                                .foregroundColor(.buttonPrimary)
                        }
                    })
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    var addCourseButton: some View{
        VStack{
            Button(action: {
                hideKeyboard()
                
//                classListViewModel.addCourse(
//                    course: CourseDefinition(
//                        courseFull: CourseFull(
//                            courseAssessments: viewModel.courseAssessments,
//                            courseTimingStructure: viewModel.timingStructure,
//                            gradeLevel: viewModel.gradeLevel,
//                            textbooks: viewModel.textbooks,
//                            learningObjectives: viewModel.learningObjectives,
//                            courseOverview: viewModel.courseOverviewSuggestions[0],
//                            prerequisites: viewModel.prerequisites,
//                            weeklyContents: []),
//                        teacherID: AppState.shared.user!.uid,
//                        sfSymbol: viewModel.selectedClassType.sfSymbol
//                    )
//                )
                
                withAnimation {
                    addCoursePressed = false
                    
                    viewModel.resetAll()
                }
            }){
                ZStack{
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(lineWidth: 2.5)
                        .foregroundColor(.buttonPrimary)
                    
                    HStack {
                        Spacer()
                        
                        if viewModel.selectedCourseIndex == -1 {
                            Image(systemName: "lock")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        } else {
                            Image(systemName: "lock.open")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        
                        Text("Add Course")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical)
                        Spacer()
                    }
                }
            }
            .padding()
            .disabled(viewModel.selectedCourseIndex == -1)
            .opacity(viewModel.selectedCourseIndex == -1 ? 0.4 : 1)
        }
    }
}



import SwiftUI
import UIKit

final class ContentSizedTextView: UITextView {

    override var intrinsicContentSize: CGSize {
        return contentSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        isScrollEnabled = false
        invalidateIntrinsicContentSize()
        layoutIfNeeded()
        isScrollEnabled = true
    }
}

struct GrowingTextView: UIViewRepresentable {

    @Binding var text: String

    func makeUIView(context: Context) -> ContentSizedTextView {
        let textView = ContentSizedTextView()
        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = false
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        textView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        return textView
    }

    func updateUIView(_ uiView: ContentSizedTextView, context: Context) {
        uiView.text = text
    }
}
