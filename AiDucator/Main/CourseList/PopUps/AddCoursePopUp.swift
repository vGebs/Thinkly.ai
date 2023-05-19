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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.black)
            
            RoundedRectangle(cornerRadius: 25)
                .stroke(lineWidth: 4)
                .foregroundColor(.buttonPrimary)
            
            header
            
            VStack {
                
                Spacer()
                    .padding(.top, 50)
                
                addTitle
                
                addDescription
                
                addStartDate
                
                addEndDate
                
                addSymbol
                
                actionButton
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .frame(width: screenWidth * 0.9, height: screenHeight / 1.7)
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
    
    var addTitle: some View {
        HStack {
            TextFieldView(
                outputText: $viewModel.className,
                inputWarning: $textIsValid,
                title: "Course Title",
                imageString: "newspaper",
                phoneOrTextfield: .textfield,
                warning: warning,
                isSecureField: false
            )
        }
        .padding(.top,2)
    }
    
    var addDescription: some View {
        HStack {
            TextFieldView(
                outputText: $viewModel.classDescription,
                inputWarning: $textIsValid,
                title: "Course Description",
                imageString: "note.text",
                phoneOrTextfield: .textfield,
                warning: warning,
                isSecureField: false
            )
        }
        .padding(.top,2)
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
                        .foregroundColor(Color.buttonPrimary)
                    
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
            .padding(.vertical)
            .padding(.top, 3)
            .disabled(!self.viewModel.titleIsValid)
            .opacity(self.viewModel.titleIsValid ? 1 : 0.4)
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
