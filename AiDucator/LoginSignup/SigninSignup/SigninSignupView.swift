//
//  SigninSignupView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import Foundation
import SwiftUI

struct SigninSignupView: View {
    
//MARK: - View State Variables
    
    @ObservedObject var viewModel: SigninSignupViewModel
    
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    @State var editingName = false
    @State var editingEmail = false
    @State var editingCellNum = false
    @State var editingPword = false
    @State var editingRePword = false
    @State var showDatePicker = false
    
//MARK: - Main Body
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ScrollView(showsIndicators: false) {
                VStack{
                    
                    Button(action: {
                        if self.viewModel.mode == .signUp{
                            withAnimation {
                                AppState.shared.onSignupView = false
                            }
                        } else {
                            withAnimation {
                                AppState.shared.onLoginView = false
                            }
                        }
                    }){
                        HStack {
                            Image(systemName: "arrow.backward")
                                .font(.system(size: 25))
                            Spacer()
                        }
                    }
                    .padding(.leading)
                    .padding(.bottom, 10)
                    
                    if viewModel.mode == .signUp {
                        title
                        subtitle
                        agePicker
                        nameTextField
                        emailTextField
                        passwordTextField
                        reEnterPasswordTextField
                        if viewModel.signUpError {
                            HStack{
                                Image(systemName: "exclamationmark.circle")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text(viewModel.signUpErrorMessage)
                                    .foregroundColor(.primary)
                            }
                        }
                        //cellNumberTextField
                    }
                    
                    if viewModel.mode == .login{
                        title
                        subtitle
                        emailTextField
                        //cellNumberTextField
                        passwordTextField
                    }
                    
                    actionButton
                }
                .offset(y: screenHeight * 0.04)
            }
            .onTapGesture {
                hideKeyboard()
            }
            
            if viewModel.loading {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                LoadingView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
//MARK: - View Variables
    
    var title: some View {
        Text(viewModel.title)
            .multilineTextAlignment(.center)
            .font(.system(size: 35, weight: .bold, design: .rounded))
    }
    
    var subtitle: some View {
        Text(viewModel.subtitle)
            .multilineTextAlignment(.center)
            .font(.system(size: 25, weight: .semibold, design: .rounded))
            .foregroundColor(.primary)
            .padding(.bottom)
    }
    
    var agePicker: some View {
        HStack{
            Image(systemName: "calendar")
                .foregroundColor(.primary)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .padding(.leading)
            
            DatePicker(
                viewModel.agePlaceholderText,
                selection: $viewModel.age,
                in: ...Date(),
                displayedComponents: .date
            )
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .padding(.trailing)
            
            if !viewModel.ageIsValid{
                Menu {
                    Text(viewModel.ageWarning)
                } label: {
                    Label("", systemImage: "exclamationmark.circle")
                        .foregroundColor(.buttonPrimary)
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .padding(.trailing)
            }
        }
    }
    
    var nameTextField: some View {
        TextFieldView(
            outputText: $viewModel.nameText,
            editing: $editingName,
            isGoingToEdit: $editingEmail,
            inputWarning: $viewModel.nameIsValid,
            title: "First Name",
            imageString: "person",
            phoneOrTextfield: .textfield,
            warning: viewModel.nameWarning,
            isSecureField: false
        )
    }
    
    var emailTextField: some View {
        TextFieldView(
            outputText: $viewModel.emailText,
            editing: $editingEmail,
            isGoingToEdit: $editingPword,
            inputWarning: viewModel.mode == .signUp ? $viewModel.emailIsValid : $viewModel.loginError,
            title: viewModel.emailPlaceholderText,
            imageString: "network",
            phoneOrTextfield: .textfield,
            warning: viewModel.mode == .signUp ? viewModel.emailWarning : viewModel.loginErrorMessage,
            isSecureField: false
        )
    }
    
    var passwordTextField: some View {
        TextFieldView(
            outputText: $viewModel.passwordText,
            editing: $editingPword,
            isGoingToEdit: $editingRePword,
            inputWarning: viewModel.mode == .signUp ? $viewModel.passwordIsValid : .constant(true),
            title: viewModel.passwordPlaceholderText,
            imageString: "lock",
            phoneOrTextfield: .textfield,
            warning: viewModel.passwordWarning,
            isSecureField: true
        )
    }
    
    var reEnterPasswordTextField: some View {
        TextFieldView(
            outputText: $viewModel.reEnterPasswordText,
            editing: $editingRePword,
            isGoingToEdit: $editingCellNum,
            inputWarning: $viewModel.rePasswordIsValid,
            title: viewModel.reEnterPasswordPlaceholderText,
            imageString: "lock.fill",
            phoneOrTextfield: .textfield,
            warning: viewModel.rePasswordWarning,
            isSecureField: true
        )
    }
    
    var cellNumberTextField: some View {
        TextFieldView(
            outputText: $viewModel.cellNumberText,
            editing: $editingCellNum,
            isGoingToEdit: $editingPword,
            inputWarning: viewModel.mode == .signUp ? $viewModel.cellNumIsValid : .constant(true),
            title: viewModel.cellNumberPlaceholder,
            imageString: "iphone",
            phoneOrTextfield: .phone,
            warning: viewModel.cellNumWarning,
            isSecureField: false
        )
    }
    
    var actionButton: some View{
        VStack{
            Button(action: {
                hideKeyboard()
                viewModel.tappedActionButton()
            }){
                ZStack{
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(lineWidth: 2.5)
                        .foregroundColor(Color.buttonPrimary)
                    
                    HStack {
                        Spacer()
                        if !viewModel.isValid {
                            Image(systemName: "lock")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        } else {
                            Image(systemName: "lock.open")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        
                        
                        Text(viewModel.buttonText)
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical)
                        Spacer()
                    }
                }
            }
            .disabled(!self.viewModel.isValid)
            .opacity(self.viewModel.isValid ? 1 : 0.4)
            .padding()
        }
    }
}

struct TextFieldView: View {
    @Binding var outputText: String
    @Binding var editing: Bool
    @Binding var isGoingToEdit: Bool
    @Binding var inputWarning: Bool

    var title: String
    var imageString: String
    var phoneOrTextfield: PhoneOrTextfield
    var warning: String
    var isSecureField: Bool

    enum PhoneOrTextfield{
        case phone
        case textfield
    }

    var body: some View {
        VStack {
            HStack {
                Image(systemName: imageString)
                    .foregroundColor(.primary)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))

                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()

                if inputWarning == false {
                    Menu {
                        Text(warning)
                    } label: {
                        Label("", systemImage: "exclamationmark.circle")
                            .foregroundColor(.buttonPrimary)
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
            }
            .padding(.horizontal)
            
            if isSecureField {
                SecureField("", text: $outputText)
                    .foregroundColor(.primary)
                    .padding()
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.accent))
                    .padding(.horizontal, 15)
                    .autocapitalization(.none)
            } else {
                TextField("", text: $outputText)
                    .foregroundColor(.primary)
                    .padding()
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.accent))
                    .padding(.horizontal, 15)
                    .autocapitalization(.none)
            }
        }
    }
}
