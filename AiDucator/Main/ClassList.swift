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

class ClassListViewModel: ObservableObject {
    
    @Published var cls: Class?
    
    var cancellables: [AnyCancellable] = []
    
    func logout() {
        AuthService.shared.logout()
    }
    
    func addClass() {
        let cls = Class(documentID: "321", title: "Physics", sfSymbol: "test", description: "Phsyics class", startDate: Date(), endDate: Date(), teacherID: "123")
//        ClassService_Firestore.shared.addClass(cls)
//            .sink { completion in
//                switch completion {
//                    case .failure(let e):
//                    print("Failed to add class")
//                    print("\(e)")
//                case .finished:
//                    print("Finished adding class")
//                }
//            } receiveValue: { _ in
//
//            }.store(in: &cancellables)

        ThinklyModel.shared.classService.addClass(cls: cls)
    }
    
    func updateClass() {
        if let _ = self.cls {
            self.cls!.sfSymbol = "srgsergsergser"
//            ClassService_Firestore.shared.updateClass(cls: cls!)
//                .sink { completion in
//                    switch completion {
//                        case .failure(let e):
//                        print("Failed to update class")
//                        print("\(e)")
//                    case .finished:
//                        print("Finished updating class")
//                    }
//                } receiveValue: { _ in
//
//                }.store(in: &cancellables)
            
            ThinklyModel.shared.classService.updateClass(cls: self.cls!)
        } else {
            print("nil nil fammm")
        }
    }
    
    func fetchClass() {
        if let c = self.cls, c.documentID != nil {
//            ClassService_Firestore.shared.getClass(with: c.documentID!)
//                .sink { completion in
//                    switch completion {
//                        case .failure(let e):
//                        print("failed to fetch class")
//                        print("\(e)")
//                    case .finished:
//                        print("Finished fetching class")
//                    }
//                } receiveValue: { [weak self] cls in
//                    self?.cls = cls
//                }.store(in: &cancellables)
            
            self.cls = ThinklyModel.shared.classService.fetchClass(with: c.documentID!)
        } else {
            print("we need docID to fetch document")
        }
    }
    
    func fetchClasses() {
//        ClassService_Firestore.shared.getClasses(for: "123")
//            .sink { completion in
//                switch completion {
//                    case .failure(let e):
//                    print("Failed to fetch classes")
//                    print("\(e)")
//                case .finished:
//                    print("Finished fetching classes")
//                }
//            } receiveValue: { [weak self] classes in
//                for cls in classes {
//                    self?.cls = cls
//                }
//            }.store(in: &cancellables)
        
        let classes = ThinklyModel.shared.classService.fetchClasses(for: "123")
        if let c = classes {
            print(c)
            self.cls = c[0]
        }
    }
    
    func deleteClass() {
        if let c = cls, c.documentID != nil {
//            ClassService_Firestore.shared.deleteClass(docID: c.documentID!)
//                .sink { completion in
//                    switch completion {
//                        case .failure(let e):
//                        print("Failed to delete class")
//                        print("\(e)")
//                    case .finished:
//                        print("Finished deleting class")
//                    }
//                } receiveValue: { [weak self] _ in
//                    self?.cls = nil
//                }.store(in: &cancellables)
            
            ThinklyModel.shared.classService.deleteClass(with: c.documentID!)
        }
    }
}

struct ClassList: View {
    let classes: [Class] = [
//        Class(title: "Math", sfSymbol: "plus.slash.minus", description: "Mathematics class", startDate: Date(), endDate: Date()),
//        Class(title: "Science", sfSymbol: "atom", description: "Science class", startDate: Date(), endDate: Date()),
//        Class(title: "History", sfSymbol: "book.closed", description: "History class", startDate: Date(), endDate: Date()),
//        Class(title: "English", sfSymbol: "textformat.abc", description: "English class", startDate: Date(), endDate: Date())
    ]

    @State var addClassPressed = false
    var temp: AnyCancellable?
    
    @StateObject var viewModel = ClassListViewModel()
    
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

            Button(action: {
                addClassPressed = true
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 5)
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
            
            if classes.count == 0 {
                Spacer()
                Text("You have no active classes")
                
                Spacer()
                
                if viewModel.cls != nil {
                    Text("\(viewModel.cls!.title)")
                    Text("\(viewModel.cls!.description)")
                    Text("\(viewModel.cls!.sfSymbol)")
                    Text("\(viewModel.cls!.teacherID)")
                    Text("\(viewModel.cls!.startDate)")
                    Text("\(viewModel.cls!.endDate)")
                    Text("\(viewModel.cls!.documentID ?? "nil")")
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.addClass()
                }) {
                    Text("Add Class")
                }.padding()
                
                Button(action: {
                    viewModel.fetchClass()
                }) {
                    Text("Fetch class")
                }.padding()
                
                Button(action: {
                    viewModel.fetchClasses()
                }) {
                    Text("fetch classes")
                }.padding()
                
                Button(action: {
                    viewModel.updateClass()
                }) {
                    Text("Update class")
                }.padding()
                
                Button(action: {
                    viewModel.deleteClass()
                }) {
                    Text("Delete class")
                }.padding()
            } else {
                List {
                    ForEach(classes, id: \.title) { item in
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
        }.sheet(isPresented: $addClassPressed) {
            AddClassForm(addClassPressed: $addClassPressed)
        }
    }
}

struct AddClassForm: View {
    @Binding var addClassPressed: Bool
    @State private var className: String = ""
    @State private var classDescription: String = ""
    @State private var durationFrom = Date()
    @State private var durationTo = Date()

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
                print("Class Name: \(className), Duration: \(durationFrom) - \(durationTo)")
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
