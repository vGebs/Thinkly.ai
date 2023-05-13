//
//  LoginSignupViewModel.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-08.
//

import Foundation
import Combine

class LandingViewModel: ObservableObject {
    //we need to move to the next view
    
    var appState = AppState.shared
    
    init() {}
    
    func signupPressed() {
        appState.onSignupView = true
    }
    
    func loginPressed() {
        appState.onLoginView = true
    }
}
