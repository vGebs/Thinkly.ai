//
//  AddCoursePopUp.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import SwiftUI

struct CourseDefinitionPopup: View {
    @ObservedObject var classListViewModel: CourseListViewModel
    @Binding var addClassPressed: Bool
    
    @StateObject var viewModel = AddCoursePopUpViewModel()
    
    @State var textIsValid = true
    var warning = "Enter the title for the class"
    
    @State var overlapPressed = true
    @State var learningObjectivePressed = true
    @State var courseOverviewPressed = true
    @State var prerequisitePressed = true
    
    @State var areYouSure = false
    @State var aiGeneratedContentComplete = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.black)
            
            
            VStack {
                ScrollView {
                    
                    header
                    
                    if !aiGeneratedContentComplete {
                        aiGeneratedPage
                    } else {
                        
                    }
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
                    if aiGeneratedContentComplete {
                        Button(action: {
                            withAnimation {
                                aiGeneratedContentComplete = false
                            }
                        }) {
                            Image(systemName: "arrowshape.backward")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.buttonPrimary)
                        }
                        .padding(.top)
                        .padding(.leading)
                    }
                    
                    Spacer()
                    Button(action: {
                        withAnimation {
                            addClassPressed = false
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
    
    var aiGeneratedPage: some View {
        VStack {
            if overlapPressed {
                hardCodedTextbooks
            } else {
                addTextbooks
            }
            
            
            if !overlapPressed {
                Divider()
                overlapButton
            } else if viewModel.loading && !learningObjectivePressed && !courseOverviewPressed && !prerequisitePressed{
                Divider()
                conceptTitleView
                LoadingView()
            } else if viewModel.errorOcurred && !learningObjectivePressed && !courseOverviewPressed && !prerequisitePressed {
                ErrorPopup {
                    withAnimation {
                        viewModel.errorOcurred = false
                        overlapPressed = false
                    }
                }
            }
            
            
            
            if viewModel.concepts.count > 0 {
                Divider()
                
                conceptsView
                
                if !learningObjectivePressed && viewModel.learningObjectives.count == 0{
                    Divider()
                    generateLearningObjectivesButton
                } else if viewModel.loading && !courseOverviewPressed && !prerequisitePressed{
                    Divider()
                    learningObjectiveTitleView
                    LoadingView()
                } else if viewModel.errorOcurred && !courseOverviewPressed && !prerequisitePressed {
                    Divider()
                    learningObjectiveTitleView
                    ErrorPopup {
                        withAnimation {
                            viewModel.errorOcurred = false
                            learningObjectivePressed = false
                        }
                    }
                }
            }
            
            
            if viewModel.learningObjectives.count > 0 {
                Divider()
                
                learningObjectivesView
                
                if !courseOverviewPressed && viewModel.courseOverviewSuggestions.count == 0 {
                    Divider()
                    generateCourseOverviewButton
                } else if viewModel.loading && !prerequisitePressed {
                    Divider()
                    courseOverViewTitleView
                    LoadingView()
                } else if viewModel.errorOcurred && !prerequisitePressed {
                    Divider()
                    courseOverViewTitleView
                    ErrorPopup {
                        withAnimation {
                            viewModel.errorOcurred = false
                            courseOverviewPressed = false
                        }
                    }
                }
            }
            
            
            if viewModel.courseOverviewSuggestions.count > 0 {
                Divider()
                
                courseOverviewView
                
                if !prerequisitePressed && viewModel.prerequisites.count == 0 {
                    Divider()
                    generatePrerequisitesButton
                } else if viewModel.loading {
                    Divider()
                    prerequisitesTitleView
                    LoadingView()
                } else if viewModel.errorOcurred {
                    Divider()
                    prerequisitesTitleView
                    
                    ErrorPopup {
                        withAnimation {
                            viewModel.errorOcurred = false
                            prerequisitePressed = false
                        }
                    }
                }
            }
            
            VStack {
                
                if viewModel.prerequisites.count > 0 {
                    Divider()
                    prerequisitesView
                }
                
                Divider()
                actionButton
                
                if viewModel.concepts.count > 0 || viewModel.learningObjectives.count > 0 || viewModel.courseOverviewSuggestions.count > 0 || viewModel.prerequisites.count > 0 {
                    Divider()
                    if !areYouSure {
                        resetAllButton
                    } else {
                        areYouSureView
                    }
                }
            }
        }
    }
    
    var hardCodedTextbooks: some View {
        VStack {
            HStack {
                Image(systemName: "newspaper")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                
                Text("Textbooks")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }.padding(.horizontal)
            
            ForEach(viewModel.textbooks.indices, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.buttonPrimary)
                    
                    VStack {
                        HStack {
                            Image(systemName: "newspaper")
                                .foregroundColor(.accent)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            
                            Text("Title")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            
                            Spacer()
                            
                        }
                        .padding(.top)
                        .padding(.horizontal)
                        
                        HStack{
                            Text(viewModel.textbooks[index].title)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        HStack {
                            Image(systemName: "person.text.rectangle")
                                .foregroundColor(.accent)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            
                            Text("Author")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack{
                            Text(viewModel.textbooks[index].author)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }.padding(.horizontal)
            }
        }
    }
    
    var addTextbooks: some View {
        VStack {
            HStack {
                Image(systemName: "newspaper")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                
                Text("Textbooks")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }.padding(.horizontal)
            ForEach(viewModel.textbooks.indices, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.buttonPrimary)
                    
                    VStack {
                        HStack {
                            TextFieldView(
                                outputText: $viewModel.textbooks[index].title,
                                inputWarning: $textIsValid,
                                title: "Title",
                                imageString: "newspaper",
                                phoneOrTextfield: .textfield,
                                warning: warning,
                                isSecureField: false
                            )
                        }
                        .padding(.top,2)
                        
                        HStack {
                            TextFieldView(
                                outputText: $viewModel.textbooks[index].author,
                                inputWarning: $textIsValid,
                                title: "Author",
                                imageString: "person.text.rectangle",
                                phoneOrTextfield: .textfield,
                                warning: warning,
                                isSecureField: false
                            )
                        }
                        .padding(.top,2)
                        
                    }
                    .padding(.vertical)
                }.padding(.horizontal)
            }
            HStack {
                if viewModel.textbooks.count > 1 {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            _ = viewModel.textbooks.popLast()
                        }
                    }) {
                        Image(systemName: "minus.square")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.accent)
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
                    Spacer()
                }
                
                Button(action: {
                    withAnimation {
                        viewModel.textbooks.append(Textbook(title: "", author: ""))
                    }
                }) {
                    Image(systemName: "plus.square")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.accent)
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
                
                if viewModel.textbooks.count > 1 {
                    Spacer()
                }
            }
        }
    }
    
    var conceptTitleView: some View {
        HStack {
            Image(systemName: "lasso.and.sparkles")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.accent)
            
            Text("Concept Overlap From Textbooks")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
        }.padding(.horizontal)
    }
    
    var conceptsView: some View {
        VStack {
            
            conceptTitleView
            
            ForEach(viewModel.concepts.indices, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.buttonPrimary)
                        
                    VStack {
                        HStack {
                            Image(systemName: "lasso.and.sparkles")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.accent)
                            Text("Concept")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if !learningObjectivePressed && viewModel.learningObjectives.count == 0 {
                                Button(action: {
                                    withAnimation {
                                        var temp = viewModel.concepts
                                        temp.remove(at: index)
                                        viewModel.concepts = temp
                                        
                                        if viewModel.concepts.count == 0 {
                                            overlapPressed = false
                                        }
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.buttonPrimary)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                            }
                        }
                        HStack {
                            Text(viewModel.concepts[index].conceptTitle)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }.padding(.bottom)
                        
                        HStack {
                            Image(systemName: "doc.plaintext")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.accent)
                            Text("Concept Description")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text(viewModel.concepts[index].descriptionOfConcept)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }.padding(.bottom)
                        
                        HStack {
                            Image(systemName: "sportscourt")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.accent)
                            Text("Concept Overlap Rating")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("\(String(viewModel.concepts[index].overlapRatingOutOfTen))/10")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                    .padding()
                }.padding(.horizontal)
            }
            if !learningObjectivePressed && viewModel.learningObjectives.count == 0 {
                HStack {
                    regenerateOverlapButton
                    
                    removeAllConcepts
                }
            }
        }
    }
    
    var removeAllConcepts: some View {
        
        Button(action: {
            withAnimation {
                overlapPressed = false
                viewModel.concepts = []
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
    
    var regenerateOverlapButton: some View {
        VStack {
            if viewModel.concepts.count > 0 {
                Button(action: {
                    withAnimation {
                        viewModel.concepts = []
                        viewModel.findTextbookOverlap()
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
    
    var generateLearningObjectivesButton: some View {
        VStack {
            if viewModel.concepts.count > 0 {
                Button(action: {
                    learningObjectivePressed = true
                    viewModel.getLearningObjectives()
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
    }
    
    var overlapButton: some View {
        VStack {
            if viewModel.textbooks.count > 1 {
                if viewModel.textbooks[1].title != "" && viewModel.textbooks[1].author != "" {
                    Button(action: {
                        if !overlapPressed && viewModel.concepts.count == 0 {
                            withAnimation {
                                overlapPressed = true
                            }
                            viewModel.findTextbookOverlap()
                        }
                    }) {
                        if viewModel.loading {
                            LoadingView()
                                .padding(.top, 5)
                        } else {
                            HStack {
                                Image(systemName: "terminal")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.accent)
                                Text("Find Concept Overlap")
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
                    }.disabled(viewModel.loading)
                }
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
                            
                            if !courseOverviewPressed && viewModel.courseOverviewSuggestions.count == 0{
                                Button(action: {
                                    withAnimation {
                                        var temp = viewModel.learningObjectives
                                        temp.remove(at: index)
                                        viewModel.learningObjectives = temp
                                        
                                        if viewModel.learningObjectives.count == 0 {
                                            learningObjectivePressed = false
                                        }
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
                            Text(viewModel.learningObjectives[index].description)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                    .padding()
                }.padding(.horizontal)
            }
            if !courseOverviewPressed && viewModel.courseOverviewSuggestions.count == 0 {
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
                learningObjectivePressed = false
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
                            viewModel.getLearningObjectives()
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
                    courseOverviewPressed = true
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
                            
                            if !prerequisitePressed && viewModel.prerequisites.count == 0 {
                                Image(systemName: viewModel.selectedCourseIndex == index ? "checkmark.square" : "square")
                                    .foregroundColor(.buttonPrimary)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
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
                    if !prerequisitePressed {
                        withAnimation {
                            if viewModel.selectedCourseIndex == index {
                                viewModel.selectedCourseIndex = -1
                            } else {
                                viewModel.selectedCourseIndex = index
                            }
                        }
                    }
                }
            }
            
            if !prerequisitePressed && viewModel.prerequisites.count == 0 {
                HStack {
                    regenerateCourseOverviewButton
                    
                    removeAllCourseOverView
                }
            }
        }
    }
    
    var removeAllCourseOverView: some View {
        Button(action: {
            withAnimation {
                courseOverviewPressed = false
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
    
    var generatePrerequisitesButton: some View {
        VStack {
            if viewModel.courseOverviewSuggestions.count > 0 {
                Button(action: {
                    prerequisitePressed = true
                    viewModel.getPrerequisites()
                }) {
                    HStack {
                        Image(systemName: "terminal")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.accent)
                        Text("Generate Prerequisites")
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
                .disabled(viewModel.selectedCourseIndex == -1)
                .opacity(viewModel.selectedCourseIndex > -1 ? 1 : 0.3)
            }
        }
    }
    
    var prerequisitesTitleView: some View {
        HStack {
            Image(systemName: "directcurrent")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.accent)
            
            Text("Prerequisites")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
        }.padding(.horizontal)
    }
    
    var prerequisitesView: some View {
        VStack {
            prerequisitesTitleView
            ForEach(viewModel.prerequisites.indices, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.buttonPrimary)
                        
                    VStack {
                        HStack {
                            Image(systemName: "directcurrent")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.accent)
                            Text("Prerequisite")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            
                            Button(action: {
                                withAnimation {
                                    var temp = viewModel.prerequisites
                                    temp.remove(at: index)
                                    viewModel.prerequisites = temp
                                    
                                    if viewModel.prerequisites.count == 0 {
                                        prerequisitePressed = false
                                    }
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.buttonPrimary)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            
                        }
                        HStack {
                            Text(viewModel.prerequisites[index].prerequisiteTitle)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }.padding(.bottom)
                        
                        HStack {
                            Image(systemName: "doc.plaintext")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.accent)
                            Text("Prerequisite Description")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text(viewModel.prerequisites[index].prerequisiteDescription)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }.padding(.bottom)
                    }
                    .padding()
                }.padding(.horizontal)
            }
            if viewModel.prerequisites.count > 0 {
                HStack {
                    regeneratePrerequisites
                }
            }
        }
    }
    
    var regeneratePrerequisites: some View {
        VStack {
            if viewModel.concepts.count > 0 {
                Button(action: {
                    withAnimation {
                        viewModel.prerequisites = []
                        viewModel.getPrerequisites()
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
    
    var addStartDate: some View {
        HStack{
            Image(systemName: "calendar")
                .foregroundColor(.accent)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .padding(.leading)
            
            DatePicker(
                "Start Date",
                selection: $viewModel.durationFrom,
                in: Date()...,
                displayedComponents: .date
            )
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .padding(.trailing)
        }
        .padding(.top,2)
    }
    
    var addEndDate: some View {
        HStack{
            Image(systemName: "calendar")
                .foregroundColor(.accent)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .padding(.leading)
            
            DatePicker(
                "End Date",
                selection: $viewModel.durationTo,
                in: Date()...,
                displayedComponents: .date
            )
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .padding(.trailing)
        }
        .padding(.top,2)
    }
    
    var addSymbol: some View {
        HStack {
            Image(systemName: "brain")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.accent)
                .padding(.leading)
            Text("Course Symbol")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Picker("Course Symbol", selection: $viewModel.selectedClassType) {
                ForEach(classTypes) { classType in
                    HStack {
                        Image(systemName: classType.sfSymbol)
                    }
                    .tag(classType)
                }
            }
            .frame(height: screenHeight / 10)
            .pickerStyle(WheelPickerStyle())
        }
        .padding(.top, 2)
    }
    
    var actionButton: some View{
        VStack{
            Button(action: {
                hideKeyboard()
                
                if aiGeneratedContentComplete {
//                    classListViewModel.addCourse(title: viewModel.className, sfSymbol: viewModel.selectedClassType.sfSymbol, description: viewModel.classDescription, startDate: viewModel.durationFrom, endDate: viewModel.durationTo)
                    withAnimation {
                        self.addClassPressed = false
                    }
                } else {
                    withAnimation {
                        aiGeneratedContentComplete = true
                    }
                }
            }){
                ZStack{
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(lineWidth: 2.5)
                        .foregroundColor(.buttonPrimary)
                    
                    HStack {
                        Spacer()
                        if viewModel.prerequisites.count == 0 {
                            Image(systemName: "lock")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        } else {
                            Image(systemName: "lock.open")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        
                        Text(aiGeneratedContentComplete ? "Add Course" : "Continue")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical)
                        Spacer()
                    }
                }
            }
            .padding()
            .disabled(viewModel.prerequisites.count == 0)
            .opacity(viewModel.prerequisites.count > 0 ? 1 : 0.4)
        }
    }
    
    var resetAllButton: some View {
        Button(action: {
            withAnimation {
                areYouSure = true
            }
        }) {
            ZStack{
                RoundedRectangle(cornerRadius: 16)
                    .stroke(lineWidth: 2.5)
                    .foregroundColor(.buttonPrimary)
                
                HStack {
                    Spacer()
                    
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    
                    Text("Reset all")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical)
                    Spacer()
                }
            }
        }
        .padding()
    }
    
    var areYouSureView: some View {
        VStack{
            Text("Are you sure you want to reset your progress")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            
            HStack {
                Button(action: {
                    withAnimation {
                        viewModel.resetAll()
                        
                        overlapPressed = false
                        learningObjectivePressed = false
                        courseOverviewPressed = false
                        prerequisitePressed = false
                        
                        areYouSure = false
                    }
                }) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(lineWidth: 2.5)
                            .foregroundColor(.buttonPrimary)
                        
                        HStack {
                            Spacer()
                            
                            Image(systemName: "trash")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            
                            Text("Yes")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.vertical)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                Button(action: {
                    withAnimation {
                        areYouSure = false
                    }
                    
                }) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(lineWidth: 2.5)
                            .foregroundColor(.buttonPrimary)
                        
                        HStack {
                            Spacer()
                            
                            Image(systemName: "xmark.square")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            
                            Text("No")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.vertical)
                            Spacer()
                        }
                    }
                }
                .padding(.trailing)
                .padding(.bottom)
            }
        }
    }
}

struct ErrorPopup: View {
    var action: () -> Void
    @State var opacity = 1.0
    
    var body: some View {
        HStack {
            Image(systemName: "figure.fall")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.accent)
            VStack {
                Text("Whoops.. we fell down..")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                Text("Please try again")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
            }
        }
        .opacity(opacity)
        .animation(.easeInOut(duration: 0.5), value: opacity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation {
                    opacity = 0
                    action()
                }
            }
        }
        .onDisappear {
            opacity = 1
        }
    }
}

struct ClassType: Identifiable, Hashable {
    let id: String
    let sfSymbol: String
}

let classTypes: [ClassType] = [
    ClassType(id: "Math", sfSymbol: "percent"),
    ClassType(id: "English Literature", sfSymbol: "book"),
    ClassType(id: "Biology", sfSymbol: "leaf.arrow.triangle.circlepath"),
    ClassType(id: "Physical Education", sfSymbol: "figure.walk"),
    ClassType(id: "History", sfSymbol: "clock"),
    ClassType(id: "Geography", sfSymbol: "globe"),
    ClassType(id: "Computer Science", sfSymbol: "desktopcomputer"),
    ClassType(id: "Art", sfSymbol: "paintbrush"),
    ClassType(id: "Music", sfSymbol: "music.note"),
    ClassType(id: "Physics", sfSymbol: "atom"),
    ClassType(id: "Astronomy", sfSymbol: "staroflife"),
    ClassType(id: "Environmental Science", sfSymbol: "tree"),
    ClassType(id: "Economics", sfSymbol: "chart.bar"),
    ClassType(id: "Sociology", sfSymbol: "person.2"),
    ClassType(id: "Languages", sfSymbol: "bubble.left.and.bubble.right"),
    ClassType(id: "Philosophy", sfSymbol: "lightbulb"),
    ClassType(id: "Health Education", sfSymbol: "heart"),
    ClassType(id: "Culinary Arts", sfSymbol: "fork.knife"),
    ClassType(id: "Political Science", sfSymbol: "building.2"),
    ClassType(id: "Psychology", sfSymbol: "brain"),
    ClassType(id: "Journalism", sfSymbol: "newspaper"),
    ClassType(id: "Business Studies", sfSymbol: "briefcase"),
    ClassType(id: "Engineering", sfSymbol: "gear"),
    ClassType(id: "Architecture", sfSymbol: "building.columns"),
    ClassType(id: "Photography", sfSymbol: "camera"),
    ClassType(id: "Design", sfSymbol: "pencil.tip.crop.circle"),
    ClassType(id: "Film Studies", sfSymbol: "film"),
    ClassType(id: "Religious Studies", sfSymbol: "book.closed"),
    ClassType(id: "Marine Biology", sfSymbol: "tortoise"),
    ClassType(id: "Anthropology", sfSymbol: "archivebox"),
    ClassType(id: "Meteorology", sfSymbol: "cloud.sun"),
    ClassType(id: "Geology", sfSymbol: "globe"),
    ClassType(id: "Forestry", sfSymbol: "leaf"),
    ClassType(id: "Veterinary Studies", sfSymbol: "bandage"),
    ClassType(id: "Robotics", sfSymbol: "gearshape.2"),
    ClassType(id: "Nursing", sfSymbol: "cross.case")
]
