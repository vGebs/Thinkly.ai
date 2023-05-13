//
//  SigninSignupViewModel.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import Combine
import Foundation
import SwiftUI

final class SigninSignupViewModel: ObservableObject{

//MARK: - General Purpose Variables
    
    private let authService = AuthService.shared
    private var cancellables: [AnyCancellable] = []

    private(set) var agePlaceholderText = "Birthday"
    private(set) var namePlaceholderText = "First name"
    private(set) var emailPlaceholderText = "Email"
    private(set) var cellNumberPlaceholder = "Cell phone number"
    private(set) var passwordPlaceholderText = "Password"
    private(set) var reEnterPasswordPlaceholderText = "Re-enter password"
    
    private(set) var ageWarning = "" //Must be 18 years of age
    private(set) var nameWarning = ""
    private(set) var emailWarning = ""
    private(set) var cellNumWarning = ""
    private(set) var passwordWarning = ""
    private(set) var rePasswordWarning = ""
    
    @Published var enterProfileTapped = false
    @Published var enterMainScreenTapped = false
    
    @Published var age = Date()
//    private(set) var cityText = LocationService.shared.city
//    private(set) var countryText = LocationService.shared.country
    @Published var nameText = ""
    @Published var emailText = ""
    @Published var cellNumberText = ""
    @Published var passwordText = ""
    @Published var reEnterPasswordText = ""
        
    @Published var ageIsValid = false
    @Published var nameIsValid = false
    @Published var emailIsValid = false
    @Published var passwordIsValid = false
    @Published var rePasswordIsValid = false
    @Published var teacherOrStudentValid = false
            
    @Published var teacherSelected = false
    @Published var studentSelected = false
    
    private var loginReady: Bool {
         emailIsValid && passwordIsValid
    }
    
    private var signupReady: Bool {
        ageIsValid &&
        nameIsValid &&
        emailIsValid &&
        passwordIsValid &&
        rePasswordIsValid &&
        teacherOrStudentValid
        
    }
    
    var isValid: Bool {
        switch mode{
        case .signUp:
            return signupReady
        case .login:
            return loginReady
        }
    }
    
    @Published var loginError = true
    let loginErrorMessage = "Username or password incorrect"
    
    @Published var signUpError = false
    let signUpErrorMessage = "This email address is already in use"
    
    @Published var loading = false
    
    let mode: Mode
    let validate: SignInSignUpValidation
    
//MARK: - Enums
    
    enum Mode {
        case login
        case signUp
    }
    
//MARK: - Initializer
    
    deinit {
        print("SigninSignupViewModel: Deinitializing")
    }
    
    init(mode: Mode){
        self.mode = mode
        self.validate = SignInSignUpValidation()
        
        switch mode{
        case .signUp:
            
            $age
                .flatMap{ [weak self] age -> AnyPublisher<Bool, Never> in
                    do {
                        try self!.validate.isAgeValid(age)
                        return Just(true).eraseToAnyPublisher()
                    } catch {
                        self!.ageWarning = error.localizedDescription
                        return Just(false).eraseToAnyPublisher()
                    }
                }
                .assign(to: &$ageIsValid)
            
            $nameText
                .flatMap{ [weak self] name -> AnyPublisher<Bool, Never> in
                    do {
                        try self!.validate.isNameValid(name)
                        return Just(true).eraseToAnyPublisher()
                    } catch {
                        self!.nameWarning = error.localizedDescription
                        return Just(false).eraseToAnyPublisher()
                    }
                }
                .assign(to: &$nameIsValid)
            
            $emailText
                .flatMap{ [weak self] email -> AnyPublisher<Bool, Never> in
                    do {
                        try self!.validate.isEmailValid(email)
                        return Just(true).eraseToAnyPublisher()
                    } catch {
                        self!.emailWarning = error.localizedDescription
                        return Just(false).eraseToAnyPublisher()
                    }
                }
                .assign(to: &$emailIsValid)
            
            $passwordText
                .flatMap{ [weak self] pword -> AnyPublisher<Bool, Never> in
                    //pword.isPasswordStringValid()
                    do {
                        try self!.validate.isPasswordValid(pword)
                        return Just(true).eraseToAnyPublisher()
                    } catch {
                        self!.passwordWarning = error.localizedDescription
                        return Just(false).eraseToAnyPublisher()
                    }
                }
                .assign(to: &$passwordIsValid)
            
            Publishers.CombineLatest($passwordText, $reEnterPasswordText)
                .flatMap{ [weak self] (pword, rPword) -> AnyPublisher<Bool, Never> in
                    //pword.isReEnterPasswordStringValid(rPword)
                    do {
                        try self!.validate.isReEnterPasswordValid(pword, rPword)
                        return Just(true).eraseToAnyPublisher()
                    } catch {
                        self!.rePasswordWarning = error.localizedDescription
                        return Just(false).eraseToAnyPublisher()
                    }
                }
                .assign(to: &$rePasswordIsValid)
            
            Publishers.CombineLatest($teacherSelected, $studentSelected)
                .flatMap { (teacher, student) -> AnyPublisher<Bool, Never> in
                    if teacher || student {
                        return Just(true).eraseToAnyPublisher()
                    } else {
                        return Just(false).eraseToAnyPublisher()
                    }
                }.assign(to: &$teacherOrStudentValid)
            
        case .login:
            
            $emailText
                .flatMap{ [weak self] email -> AnyPublisher<Bool, Never> in
                    do {
                        try self!.validate.isEmailValid(email)
                        return Just(true).eraseToAnyPublisher()
                    } catch {
                        self!.emailWarning = error.localizedDescription
                        return Just(false).eraseToAnyPublisher()
                    }
                }
                .assign(to: &$emailIsValid)
            
            $passwordText
                .flatMap { [weak self] pword -> AnyPublisher<Bool, Never> in
                    do {
                        try self!.validate.isPasswordValid(pword)
                        return Just(true).eraseToAnyPublisher()
                    } catch {
                        self!.passwordWarning = error.localizedDescription
                        return Just(false).eraseToAnyPublisher()
                    }
                }
                .assign(to: &$passwordIsValid)
        }
    }
    
//MARK: - Mode Specific View Variables
    
    var title: String {
        switch mode {
        case .signUp:
            return "Create an Account"
        case .login:
            return "Welcome Back"
        }
    }
    
    var subtitle: String{
        switch mode {
        case .signUp:
            return "Sign up with your email"
        case .login:
            return "Sign in with your email"
        }
    }
    
    var buttonText: String {
        switch mode {
        case .signUp:
            return "Sign up!"
        case .login:
            return "Log in!"
        }
    }

//MARK: - Public Methods
    
    func tappedActionButton(){
        switch mode{
        case .signUp:
            createAccount()
        
        case .login:
            login()
        }
    }
    
//MARK: - Private functions
        
    private func createAccount(){
        print("signup")
        self.loading = true
        authService.signUp(self.emailText, self.passwordText)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] completion in
                switch completion {
                case let .failure(error):
                    print(error.localizedDescription)
                    self!.signUpError = true
                    self!.loading = false
                case .finished:
                    print("Succesfully Signed up")
                }
            } receiveValue: { [weak self] _ in
                //once we sign up we now enter the main page
                AppState.shared.onMainView = true
                self?.loading = false
            }
            .store(in: &cancellables)
    }
    
    private func login(){
        print("login")
        self.loading = true
        authService.signIn(self.emailText, self.passwordText)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case let .failure(error):
                    print("SignInSignUpViewModel: Failed to login")
                    print("SignInSignUpViewModel-err: \(error)")
                    self!.loginError = false
                    self!.loading = false
                case .finished:
                    print("Succesfully Signed in")
                }
            } receiveValue: { [weak self] _ in
                AppState.shared.onMainView = true
                self?.loading = false
            }
            .store(in: &cancellables)
    }
}

