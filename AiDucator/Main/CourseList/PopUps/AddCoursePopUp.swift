//
//  AddCoursePopUp.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import SwiftUI

struct AddCoursePopUp: View {
    @ObservedObject var classListViewModel: CourseListViewModel
    @Binding var addClassPressed: Bool
    
    @StateObject var viewModel = AddCoursePopUpViewModel()
    
    @State var textIsValid = true
    var warning = "Enter the title for the class"
    
    @State var overlapPressed = true
    @State var learningObjectivePressed = false
    @State var courseOverviewPressed = false
    @State var prerequisitePressed = false
    
    @State var areYouSure = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.black)
            
            
            VStack {
                ScrollView {
                    
                    header
                    
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
                        LoadingView()
                    }
                    
                    
                    
                    if viewModel.concepts.count > 0 {
                        Divider()
                        
                        conceptsView
                        
                        if !learningObjectivePressed && viewModel.learningObjectives.count == 0{
                            Divider()
                            generateLearningObjectivesButton
                        } else if viewModel.loading && !courseOverviewPressed && !prerequisitePressed{
                            Divider()
                            LoadingView()
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
                            LoadingView()
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
                            LoadingView()
                        }
                    }
                    
                    VStack {
                        Divider()
                        
                        if viewModel.prerequisites.count > 0 {
                            prerequisitesView
                        }
                        
                        actionButton
                        
                        if viewModel.concepts.count > 0 || viewModel.learningObjectives.count > 0 || viewModel.courseOverviewSuggestions.count > 0 || viewModel.prerequisites.count > 0 {
                            if !areYouSure {
                                resetAllButton
                            } else {
                                areYouSureView
                            }
                            
                        }
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
                    .padding(.leading)
                    Spacer()
                }
                Spacer()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Text("Add Course")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top)
                    Spacer()
                }
                Spacer()
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
                    Button(action: {
                        withAnimation {
                            _ = viewModel.textbooks.popLast()
                        }
                    }) {
                        Text("Remove textbook")
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
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                Button(action: {
                    withAnimation {
                        viewModel.textbooks.append(Textbook(title: "", author: ""))
                    }
                }) {
                    Text("Add textbook")
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
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }
    
    var conceptsView: some View {
        VStack {
            HStack {
                Image(systemName: "lasso.and.sparkles")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                
                Text("Concept Overlap From Textbooks")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }.padding(.horizontal)
            
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
                    
                    addOneConceptButton
                }
            }
        }
    }
    
    var addOneConceptButton: some View {
        
        Button(action: {
            
        }) {
            ZStack {
                
                Image(systemName: "plus.square")
                    .font(.system(size: 24, weight: .regular, design: .rounded))
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
    
    var regenerateOverlapButton: some View {
        VStack {
            if viewModel.concepts.count > 0 {
                Button(action: {
                    viewModel.concepts = []
                    viewModel.findTextbookOverlap()
                }) {
                    HStack {
                        ZStack {
                            Image(systemName: "square")
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
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
                    Text("Generate Learning Objectives")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
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
                            Text("Find Concept Overlap")
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
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }.disabled(viewModel.loading)
                }
            }
        }
    }
    
    var learningObjectivesView: some View {
        VStack {
            HStack {
                Image(systemName: "lightbulb")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                
                Text("Learning Objectives")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }.padding(.horizontal)
            
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
                    addOneLearningObjectiveButton
                }
            }
        }
    }
    
    var addOneLearningObjectiveButton: some View {
        
        Button(action: {
            
        }) {
            ZStack {
                
                Image(systemName: "plus.square")
                    .font(.system(size: 24, weight: .regular, design: .rounded))
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
    
    var regenerateLearningObjectivesButton: some View {
        VStack {
            if viewModel.learningObjectives.count > 0 {
                Button(action: {
                    viewModel.learningObjectives = []
                    viewModel.getLearningObjectives()
                }) {
                    HStack {
                        ZStack {
                            Image(systemName: "square")
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
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
                    Text("Generate Course Title")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
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
    
    var courseOverviewView: some View {
        VStack {
            HStack {
                Image(systemName: "highlighter")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                
                Text("Course")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }.padding(.horizontal)
            
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
                            
                            
//                            Button(action: {
//                                withAnimation {
//                                    var temp = viewModel.courseOverviewSuggestions
//                                    temp.remove(at: index)
//                                    viewModel.courseOverviewSuggestions = temp
//
//                                    if viewModel.courseOverviewSuggestions.count == 0 {
//                                        courseOverviewPressed = false
//                                    }
//                                }
//                            }) {
//                                Image(systemName: "trash")
//                                    .foregroundColor(.buttonPrimary)
//                                    .font(.system(size: 16, weight: .bold, design: .rounded))
//                            }
                            
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
                    
                    addOneCourseOverviewButton
                    
                    resetCourseOverView
                }
            }
        }
    }
    
    var resetCourseOverView: some View {
        Button(action: {
            viewModel.courseOverviewSuggestions = []
        }) {
            ZStack {
                
                Text("Reset")
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
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
    
    var addOneCourseOverviewButton: some View {
        
        Button(action: {
            
        }) {
            ZStack {
                
                Image(systemName: "plus.square")
                    .font(.system(size: 24, weight: .regular, design: .rounded))
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
    
    var regenerateCourseOverviewButton: some View {
        VStack {
            if viewModel.courseOverviewSuggestions.count > 0 {
                Button(action: {
                    viewModel.courseOverviewSuggestions = []
                    viewModel.getCourseTitleSuggestion()
                }) {
                    HStack {
                        ZStack {
                            Image(systemName: "square")
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
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
                    Text("Generate Prerequisites")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
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
    
    var prerequisitesView: some View {
        VStack {
            HStack {
                Image(systemName: "directcurrent")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                
                Text("Prerequisites")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }.padding(.horizontal)
            
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
                classListViewModel.addCourse(title: viewModel.className, sfSymbol: viewModel.selectedClassType.sfSymbol, description: viewModel.classDescription, startDate: viewModel.durationFrom, endDate: viewModel.durationTo)
                withAnimation {
                    self.addClassPressed = false
                }
            }){
                ZStack{
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(lineWidth: 2.5)
                        .foregroundColor(.buttonPrimary)
                    
                    HStack {
                        Spacer()
                        if !viewModel.titleIsValid {
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
            .padding(.horizontal)
            .padding(.bottom)
            .padding(.top, 3)
            .disabled(!self.viewModel.titleIsValid)
            .opacity(self.viewModel.titleIsValid ? 1 : 0.4)
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
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    var areYouSureView: some View {
        VStack{
            Text("Are you sure you want to rest your progress")
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
