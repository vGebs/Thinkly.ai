//
//  AppState.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-08.
//

import Foundation
import Combine

class AppState: ObservableObject {
    
    static let shared = AppState()
    
    @Published var onLandingView = true
    @Published var onLoginView = false
    @Published var onSignupView = false
    
    @Published var onMainView = false
    
    private var cancellables: [AnyCancellable] = []
    
    private init() {
        
        $onLandingView
            .sink { [weak self] onLoginSignup in
                if onLoginSignup {
                    self?.onLoginView = false
                    self?.onSignupView = false
                }
            }.store(in: &cancellables)
        
        $onLoginView
            .sink { [weak self] onLogin in
                if onLogin {
                    self?.onLandingView = false
                }
            }.store(in: &cancellables)
        
        $onSignupView
            .sink { [weak self] onSignup in
                if onSignup {
                    self?.onLandingView = false
                }
            }.store(in: &cancellables)
        
        $onMainView
            .sink { [weak self] onMain in
                if onMain {
                    self?.onLoginView = false
                    self?.onSignupView = false
                    self?.onLandingView = false
                }
            }.store(in: &cancellables)
        
        Publishers.CombineLatest3($onMainView, $onLoginView, $onSignupView)
            .flatMap { (onMain, onLogin, onSignup) -> AnyPublisher<Bool, Never> in
                if !onMain && !onLogin && !onSignup {
                    return Just(true).eraseToAnyPublisher()
                } else {
                    return Just(false).eraseToAnyPublisher()
                }
            }.assign(to: &$onLandingView)
        
        AuthService.shared.listen()
        
        AuthService.shared.$user
            .sink { [weak self] user in
                if let _ = user {
                    self?.onMainView = true
                }
            }.store(in: &cancellables)
    }
}
