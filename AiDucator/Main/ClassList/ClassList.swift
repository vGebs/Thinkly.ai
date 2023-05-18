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


struct ClassList: View {

    @StateObject var viewModel = ClassListViewModel()
    
    @State var addClassPressed = false
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "newspaper")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.buttonPrimary)
                    .padding(.leading)
                Text("Classes")
                    .foregroundColor(.primary)
                    .font(.largeTitle)
                    
                Spacer()
                
                Button(action: {
                    viewModel.logout()
                }) {
                    Text("Logout")
                }
            }.padding(.top)
            
            if viewModel.loading {
                LoadingView()
            } else {
                Button(action: {
                    addClassPressed = true
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
                
                if viewModel.user!.classes == nil {
                    Spacer()
                    
                    Text("You have no active classes")
                    
                    Spacer()
                    
                } else {
                    if viewModel.user!.classes!.count == 0 {
                        
                    } else {
                        List {
                            ForEach(viewModel.user!.classes!, id: \.title) { item in
                                Button(action: {
                                    print("Tapped on \(item.title)")
                                }) {
                                    HStack {
                                        Image(systemName: item.sfSymbol)
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.buttonPrimary)
                                            .frame(width: 20, height: 20)
                                        
                                        VStack(alignment: .leading) {
                                            Text(item.title)
                                                .font(.title2)
                                                .foregroundColor(.primary)
                                            
                                            Text(item.description)
                                                .foregroundColor(.secondary)
                                                .font(.subheadline)
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
        }.sheet(isPresented: $addClassPressed) {
            AddClassForm(classListViewModel: viewModel, addClassPressed: $addClassPressed)
        }
    }
}

struct ClassType: Identifiable, Hashable {
    let id: String
    let sfSymbol: String
}

let classTypes: [ClassType] = [
    ClassType(id: "Math", sfSymbol: "function"),
    ClassType(id: "English", sfSymbol: "book.closed"),
    ClassType(id: "History", sfSymbol: "clock"),
    ClassType(id: "Geography", sfSymbol: "map"),
    ClassType(id: "Art", sfSymbol: "paintpalette"),
    ClassType(id: "Music", sfSymbol: "music.note"),
    ClassType(id: "Physical Education", sfSymbol: "figure.walk"),
    ClassType(id: "Computer Science", sfSymbol: "desktopcomputer"),
    ClassType(id: "Physics", sfSymbol: "waveform.path.ecg"),
    ClassType(id: "Biology", sfSymbol: "leaf"),
    ClassType(id: "Chemistry", sfSymbol: "flask"),
    ClassType(id: "Economics", sfSymbol: "chart.bar"),
    ClassType(id: "Astronomy", sfSymbol: "telescope"),
    ClassType(id: "Psychology", sfSymbol: "brain"),
    ClassType(id: "Environmental Studies", sfSymbol: "sun.max"),
    ClassType(id: "Photography", sfSymbol: "camera"),
    ClassType(id: "Foreign Languages", sfSymbol: "globe"),
    ClassType(id: "Cooking/Culinary Arts", sfSymbol: "fork.knife"),
]

struct AddClassForm: View {
    @ObservedObject var classListViewModel: ClassListViewModel
    @Binding var addClassPressed: Bool
    @State private var className: String = ""
    @State private var classDescription: String = ""
    @State private var durationFrom = Date()
    @State private var durationTo = Date()
    @State private var selectedClassType = ClassType(id: "Math", sfSymbol: "function")

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    addClassPressed.toggle()
                }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
                .padding(.leading)
                .padding(.top)
                
                Spacer()
            }
            
            Spacer()
            
            Text("Add Class")
                .font(.largeTitle)
                .padding()

            TextField("Class Name", text: $className)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Picker("Class Type", selection: $selectedClassType) {
                ForEach(classTypes) { classType in
                    HStack {
                        Image(systemName: classType.sfSymbol)
                        Text(classType.id)
                    }
                    .tag(classType)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            
            TextField("Class Description", text: $classDescription)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            VStack(alignment: .leading) {
                Text("Duration")
                    .font(.headline)

                HStack {
                    DatePicker("From", selection: $durationFrom, displayedComponents: [.date])
                        .labelsHidden()
                        .datePickerStyle(CompactDatePickerStyle())

                    DatePicker("To", selection: $durationTo, displayedComponents: [.date])
                        .labelsHidden()
                        .datePickerStyle(CompactDatePickerStyle())
                }
            }
            .padding(.vertical)

            Button("Add Class") {
                classListViewModel.addClass(title: className, sfSymbol: selectedClassType.sfSymbol, description: classDescription, startDate: durationFrom, endDate: durationTo)
                
                addClassPressed = false
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
        .onTapGesture {
            hideKeyboard()
        }
    }
}
