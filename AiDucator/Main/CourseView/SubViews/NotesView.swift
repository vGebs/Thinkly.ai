//
//  NotesView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import SwiftUI

struct NotesView: View {
    
    @StateObject var viewModel = NotesViewModel()
    @State var showAutoGenPopup = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ScrollView {
                    
                    ForEach(viewModel.chapters) { chapter in
                        MyUnitsDropDown(chapter: chapter, popup: true)
                            .padding(.horizontal, 5)
                    }
                    .padding(.top, screenHeight * 0.01)
                    
                    if let user = AppState.shared.user {
                        if user.role == "teacher" {
                            
                            Divider()
                            
                            if showTextField {
                                titleTextFieldView
                            } else {
                                HStack {
                                    addChapterButton
                                    generateOutline
                                }.frame(width: screenWidth * 0.9)
                            }
                        }
                    }
                    
                    Spacer().padding(.bottom, screenHeight * 0.13)
                }
                .frame(width: screenWidth, height: screenHeight * (1 - 0.11))
            }
            .disabled(showAutoGenPopup)
            .blur(radius: showAutoGenPopup ? 10 : 0)
            .onTapGesture {
                hideKeyboard()
                withAnimation {
                    showAutoGenPopup = false
                }
            }
            if showAutoGenPopup {
                AutoGenPopup()
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: screenWidth, height: screenHeight)
    }
    
    var generateOutline: some View {
        Button(action: {
            withAnimation {
                showAutoGenPopup = true
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
                    Text("Auto-Gen")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding()
            }
            .padding(.top, 5)
        }
    }
    
    @State var showTextField = false
    @State var chapterTitle = ""
    
    var addChapterButton: some View {
        Button(action: {
            showTextField = true
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.black)
                RoundedRectangle(cornerRadius: 20)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                HStack {
                    Image(systemName: "plus.app")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                        .padding(.leading, 5)
                    Text("Add Module")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding()
            }
            .padding(.top, 5)
        }
    }
    
    
    var titleTextFieldView: some View {
        ZStack {
            TextField("Enter chapter title", text: $chapterTitle)
                .padding()
                .background(Color.black)
                .cornerRadius(20)
                .padding(.top, 5)
                .frame(width: UIScreen.main.bounds.width * 0.9)
            
            HStack {
                Spacer()
                Button(action: {
                    viewModel.addChapter(title: chapterTitle)
                    chapterTitle = ""
                    showTextField = false
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                }
                
                Button(action: {
                    chapterTitle = ""
                    showTextField = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                }
                .padding(.trailing)
            }.padding(.trailing)
        }
    }
}


import Combine

//for this class we need to fetch all of the notes for that class.
//So for the course they are in, fetch all of the notes,

class NotesViewModel: ObservableObject {
    @Published var chapters: [Chapter] = [
        Chapter(title: "Intro", notes: [
            Note(title: "Intro to this course", content: ""),
            Note(title: "Sylabus", content: "")
        ]),
        Chapter(title: "Big stuff", notes: [
            Note(title: "This is the big stuff", content: "")
        ]),
        Chapter(title: "Final notes", notes: [
            Note(title: "Final info and shit", content: "")
        ])
    ]
    
    func addChapter(title: String) {
        guard title != "" else { return }
        
        let chapter = Chapter(title: title, notes: [])
        self.chapters.append(chapter)
    }
}


struct MyUnitsDropDown: View {
    @State var expanded = false
    var chapter: Chapter
    var popup: Bool
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.black)
            RoundedRectangle(cornerRadius: 15)
                .stroke()
                .foregroundColor(.accent)

            VStack {
                unitPlaceholder
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.2)) {
                            expanded.toggle()
                        }
                    }
                
                if expanded && chapter.notes.count > 0 {
                    Divider()
                        .frame(width: screenWidth * 0.9)
                    
                    ForEach(chapter.notes) { note in
                        Button(action: {
                            //view note
                        }) {
                            HStack {
                                Image(systemName: "dot.square")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.accent)
                                
                                Text(note.title)
                                    .font(.system(size: 18, weight: .regular, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(.buttonPrimary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }.padding(.top)
                    
                    Divider()
                    
                    if let user = AppState.shared.user {
                        if user.role == "teacher" {
                            Button(action: {
                                
                            }) {
                                HStack {
                                    Image(systemName: "plus.app")
                                        .font(.system(size: 15, weight: .regular, design: .rounded))
                                        .foregroundColor(.buttonPrimary)
                                    
                                    Text("Add Notes")
                                        .font(.system(size: 18, weight: .regular, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.bottom)
                            }.padding(.top)
                        }
                    }
                }
            }
        }
        .frame(width: screenWidth * 0.9)
    }
    
    var unitPlaceholder: some View {
        HStack {
            Image(systemName: "newspaper")
                .foregroundColor(.buttonPrimary)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .padding(.horizontal)
            
            Text(chapter.title)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            if chapter.notes.count > 0 {
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.buttonPrimary)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .padding(.trailing)
            } else {
                Button(action: {
                    // Action to add note
                }) {
                    Image(systemName: "plus.app")
                        .foregroundColor(.buttonPrimary)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .padding(.trailing)
                }
            }
        }
        .padding(.vertical)
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
