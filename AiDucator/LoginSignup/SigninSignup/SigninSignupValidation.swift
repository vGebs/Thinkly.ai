//
//  SigninSignupValidation.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import Foundation
import Foundation
import Combine

struct SignInSignUpValidation {
    func isAgeValid(_ age: Date?) throws {
        guard let age = age else { throw SignInSignUpError.invalidValue }
        
        let today = Date()
        
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        let check = gregorian.components([.year], from: age, to: today, options: [])
        
        if check.year! < 5 {
            throw SignInSignUpError.invalidAge
        }
    }
    
    func isNameValid(_ name: String?) throws {
        guard let name = name else { throw SignInSignUpError.invalidValue }
        guard name.count > 1 else { throw SignInSignUpError.nameTooShort }
        guard name.count < 14 else { throw SignInSignUpError.nameTooLong }
        //Check name contains only alpha
        //Check name has no spaces
    }
    
    func isEmailValid(_ email: String?) throws {
        guard let email = email else { throw SignInSignUpError.invalidValue }
        
        guard emailFormValidator(email) else { throw SignInSignUpError.invalidEmail }
    }
    
    func isCellValid(_ num: String?) throws {
        guard let num = num else { throw SignInSignUpError.invalidValue }
        
        guard num.count == 14 else { throw SignInSignUpError.invalidCell }
    }
    
    func isPasswordValid(_ pword: String?) throws {
        guard let pword = pword else { throw SignInSignUpError.invalidValue }
        guard pword.count > 5 else { throw SignInSignUpError.passwordTooShort }
        guard pword.count < 21 else { throw SignInSignUpError.passwordTooLong }
        //Check for uppercase
        //Check for lowercase
        //Check for number
        //Check for spaces
    }
    
    func isReEnterPasswordValid(_ pword: String?, _ pword2: String?) throws {
        guard let pword = pword else { throw SignInSignUpError.invalidValue }
        guard let pword2 = pword2 else { throw SignInSignUpError.invalidValue }
        
        guard pword == pword2 else { throw SignInSignUpError.rePasswordDoesNotMatch }
    }
    
    enum SignInSignUpError: LocalizedError {
        case invalidValue
        
        case invalidAge
        
        case nameTooShort
        case nameTooLong
        case nameMustContainOnlyAlpha
        case nameMustNotHaveSpaces
        
        case invalidEmail
        
        case invalidCell
        
        case passwordTooShort
        case passwordTooLong
        case passwordDoesNotContainUpper
        case passwordDoesNotContainLower
        case passwordDoesNotContainNumber
        case passwordMustNotHaveSpaces
        
        case rePasswordDoesNotMatch
        
        var errorDescription: String? {
            switch self {
            case .invalidValue:
                return "Value entered is invalid"
                
            case .invalidAge:
                return "Must be at least 5 years of age"
                
            case .nameTooShort:
                return "Name must be 2 characters or longer"
                
            case .nameTooLong:
                return "Name must be less than 14 characters"
                
            case .nameMustContainOnlyAlpha:
                return "Name must only contain alphabetical characters"
                
            case .nameMustNotHaveSpaces:
                return "Name must not have spaces"
                
            case .invalidEmail:
                return "Must input a valid email format: x@x.xx"
                
            case .invalidCell:
                return "Must be in form xxx-xxx-xxxx"
                
            case .passwordTooShort:
                return "Password must be at least 6 characters"
                
            case .passwordTooLong:
                return "Password Must be no longer than 20 characters"
                
            case .passwordDoesNotContainUpper:
                return "Password must contain at least 1 uppercase letter"
                
            case .passwordDoesNotContainLower:
                return "Password must contain at least 1 lowercase letter"
                
            case .passwordDoesNotContainNumber:
                return "Password must contain at least one number"
                
            case .passwordMustNotHaveSpaces:
                return "Password must not have spaces"
                
            case .rePasswordDoesNotMatch:
                return "Re entered password does not match"
            }
        }
    }
}

extension SignInSignUpValidation {
    private func emailFormValidator(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if emailPred.evaluate(with: email){
            return true
        } else {
            return false
        }
    }
}
