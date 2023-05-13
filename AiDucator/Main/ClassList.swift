//
//  MainView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import SwiftUI


//I am making the main educator view right now.
//I'll need to fetch for all of the classes that teacher is teaching
// The class will simply have a Class ID that students can use to login to the class

import SwiftUI
import Combine

struct Class {
    let title: String
    let sfSymbol: String
    let description: String
    let startDate: Date
    let endDate: Date
}

class ClassListViewModel: ObservableObject {
    
    @Published var user: User?
    
    var cancellables: [AnyCancellable] = []
    
    func logout() {
        AuthService.shared.logout()
    }
    
    func addUser() {
        UserService.shared.createUser(User(name: "Vaughn", role: "Student", uid: AuthService.shared.user!.uid, birthdate: Date()))
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("Failed to push user")
                    print("\(e)")
                case .finished:
                    print("pushed user")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)

//        UserService_CoreData.shared.createUser(User(name: "Vaughn", role: "Student", uid: "123", birthdate: Date()))
    }
    
    func updateName() {
        if user != nil {
            user!.name = "VVV"
            UserService.shared.updateName(user!, docID: user!.documentID!)
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("Failed to update user")
                        print("\(e)")
                    case .finished:
                        print("updated user")
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)
        } else {
            print("ahwbdajhw")
        }
        
//        UserService_CoreData.shared.updateName(name: "VVV", uid: "123")
    }
    
    func fetchUser() {
        UserService.shared.fetchUser(with: AuthService.shared.user!.uid)
            .sink { completion in
                switch completion {
                case .failure(let e):
                    print("Failed to fetch user")
                    print("\(e)")
                case .finished:
                    print("fetched user")
                }
            } receiveValue: { [weak self] user in
                print("got it")
                if let u = user {
                    self?.user = user
                } else {
                    print("nil nil fam")
                }
            }
            .store(in: &cancellables)
        
        //self.user = UserService_CoreData.shared.fetchUser(uid: "123")
    }
    
    func deleteUser() {
        if user != nil {
            UserService.shared.deleteUser(user: user!)
                .sink { completion in
                    switch completion {
                    case .failure(let e):
                        print("Failed to delete user")
                        print("\(e)")
                    case .finished:
                        print("deleted user")
                    }
                } receiveValue: { [weak self] _ in
                    self?.user = nil
                }
                .store(in: &cancellables)
        }
        
//        if let u = user {
//            UserService_CoreData.shared.deleteUser(uid: u.uid)
//        } else {
//            print("nanana")
//        }
        
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
                
                if viewModel.user != nil {
                    Text("\(viewModel.user!.name)")
                    Text("\(viewModel.user!.role)")
                    Text("\(viewModel.user!.uid)")
                    Text("\(viewModel.user!.birthdate)")
                    Text("\(viewModel.user!.documentID ?? "nil")")
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.addUser()
                }) {
                    Text("Add user")
                }.padding()
                Button(action: {
                    viewModel.fetchUser()
                }) {
                    Text("Fetch User")
                }.padding()
                Button(action: {
                    viewModel.updateName()
                }) {
                    Text("Change name")
                }.padding()
                
                Button(action: {
                    viewModel.deleteUser()
                }) {
                    Text("Delete user")
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
