//
//  SelfLearnCourseDefinitionSheet.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-07-14.
//

import SwiftUI

struct SelfLearnCourseDefinitionSheet: View {
    
    @State var onCourseNamePage = false
    @ObservedObject var selfLearnCourseDefinitionSheetViewModel: SelfLearnCourseDefinitionSheetViewModel
    
    var body: some View {
        if !onCourseNamePage {
            CurriciulumSelectView(viewModel: selfLearnCourseDefinitionSheetViewModel, curriculumSelected: $onCourseNamePage)
        } else {
            CourseNameSelectView(viewModel: CourseNameViewModel(curriculum: selfLearnCourseDefinitionSheetViewModel.selectedCurriculum!), onCourseNamePage: $onCourseNamePage)
        }
    }
}

import Combine

class CourseNameViewModel: ObservableObject {
    @Published var courseOverviewSuggestions: [CourseOverview] = []
    @Published var selectedCourseIndex = -1
    @Published private(set) var loading = false
    @Published var selectedClassType = ClassType(id: "Computer Science", sfSymbol: "desktopcomputer")

    private var cancellables: [AnyCancellable] = []
    
    let curriculum: Curriculum
    
    let courseDefService: CourseDefinitionService
    
    init(curriculum: Curriculum) {
        self.curriculum = curriculum
        self.courseDefService = CourseDefinitionService()
    }
    
    func getCourseTitleSuggestion() {
        self.loading = true
        courseDefService.getCourseTitleSuggestionsFromCurriculum(from: curriculum.units)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let e):
                    print("SelfLearnCourseDefinitionViewModel: Failed to get course title suggestions")
                    print("SelfLearnCourseDefinitionViewModel: \(e)")
                    
                    withAnimation {
//                        self?.errorOcurred = true
                        self?.loading = false
                    }
                case .finished:
                    print("SelfLearnCourseDefinitionViewModel: Finished getting course title suggestions")
                }
            } receiveValue: { [weak self] suggestions in
                withAnimation {
                    var final: [CourseOverview] = []
                    
                    for sug in suggestions.courseOverview {
                        final.append(CourseOverview(courseTitle: sug.courseTitle, courseDescription: sug.courseDescription))
                    }
                    
                    self?.courseOverviewSuggestions = final
                    self?.loading = false
                }
            }.store(in: &cancellables)
    }
    
    func stopGenerating() {
        cancellables = []
        loading = false
        selectedCourseIndex = -1
    }
    
    func createCourse() {
        //we need to first push the course to firestore, get the docID(the course ID) from the course,
        //  then we need to push the curriculum to firestore with the courseID
        
        var title = courseOverviewSuggestions[selectedCourseIndex]
        title.sfSymbol = selectedClassType.sfSymbol
        title.teacherID = AppState.shared.user!.uid
        CourseService_Firestore.shared.addCourse(title)
            .flatMap { [weak self] docID in
                UnitService_firestore.shared.pushUnits(units: self!.curriculum.units, courseID: docID)
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("CourseNameViewModel: Failed to push course")
                    print("CourseNameViewModel-err: \(e)")
                case .finished:
                    print("CourseNameViewModel: Finished pushing new course")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}

struct CourseNameSelectView: View {
    @ObservedObject var viewModel: CourseNameViewModel
    @Binding var onCourseNamePage: Bool
    
    var body: some View {
        ZStack {
            Color.black
            VStack {
                ScrollView {
                    preWarning
                        .padding(.top)
                    if !viewModel.loading {
                        if viewModel.courseOverviewSuggestions.count == 0 {
                            generateCourseOverviewButton
                        } else {
                            courseOverviewView
                            addSymbol
                            createCourseButton
                        }
                    } else if viewModel.loading {
                        LoadingView()
                            .padding(.bottom)
                        stopGeneratingButton
                    }
                    
                    Spacer().padding(.bottom, screenHeight * 0.05)
                }
            }
        }.edgesIgnoringSafeArea(.all)
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
                    
                    Text("Time to pick a name for your course!!")
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
            }.padding()
        }
        .padding(.bottom)
        .padding(.horizontal)
    }
    
    var stopGeneratingButton: some View {
        Button(action: {
            viewModel.stopGenerating()
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
    
    var generateCourseOverviewButton: some View {
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
    
    var createCourseButton: some View {
        Button(action: {
            viewModel.createCourse()
        }) {
            HStack {
                Image(systemName: "note.text.badge.plus")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                Text("Create Course")
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
        .opacity(viewModel.selectedCourseIndex == -1 ? 0.4 : 1.0)
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
    
    var regenerateCourseOverviewButton: some View {
        VStack {
            if viewModel.courseOverviewSuggestions.count > 0 {
                Button(action: {
                    withAnimation {
                        viewModel.selectedCourseIndex = -1
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
}

struct CurriciulumSelectView: View {
    
    @ObservedObject var viewModel: SelfLearnCourseDefinitionSheetViewModel
    @State var selectedVersion = 0
    @Binding var curriculumSelected: Bool
    
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
                
                if viewModel.curriculums[0].units.count == 0 {
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
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    var body: some View {
        
         ZStack {
             Color.black
             VStack {
                Spacer()
                ScrollView {
                    
                    userPrompt
                    
                    if viewModel.curriculums[0].units.count == 0 {
                        if viewModel.userPrompt.count > 2 {
                            preWarning
                                .padding(.top)
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
                    
                    if viewModel.curriculums[0].units.count > 0 {
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
                        
                            continueWithCurriculumButton
                            
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
                                    UnitDropDown(unit: $viewModel.curriculums[selectedVersion].units[index], subunitsActive: false, notesViewModel: NotesViewModel(dummyClass: true))
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
                    
                    
//                    if viewModel.curriculums[0].units.count == 0 {
//
//                        preWarning
//                        if viewModel.errorOccurred == selectedVersion {
//                            errorWarning
//                        }
//
//                        if viewModel.loading {
//                            LoadingView()
//                                .padding(.bottom)
//                            stopGeneratingButton
//                        } else {
//                            HStack {
//                                Spacer()
//                                generatePreliminaryCurriculumButton
//                                Spacer()
//                            }.padding(.horizontal)
//                        }
//                    }
                    
                    Spacer().padding(.bottom, screenHeight * 0.13)
                }
                .frame(width: screenWidth, height: screenHeight * (1 - 0.11))
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: screenWidth, height: screenHeight)
        .onTapGesture {
            hideKeyboard()
        }
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
    
    var continueWithCurriculumButton: some View {
        Button(action: {
            curriculumSelected = true
            viewModel.selectCurriculum(selectedVersion: selectedVersion)
//            viewModel.submitUnits(selectedVersion)
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
                    
                    Text("Press 'Generate' to create some curriculums for your course.")
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
            }.padding()
        }
        .padding(.bottom)
        .padding(.horizontal)
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
        }
        .padding(.horizontal)
        .padding(.top)
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
        .disabled(viewModel.userPrompt.count < 3)
        .opacity(viewModel.userPrompt.count < 3 ? 0.4 : 1)
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
