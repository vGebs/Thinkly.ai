//
//  AuthService.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import FirebaseAuth
import Combine

class AuthService: ObservableObject {
    
    static let shared = AuthService()
    
    @Published var user: FirebaseAuth.User?
    
    private var authListener: AnyCancellable?
    
    private var cancellables: [AnyCancellable] = []
    
    private init() {
        self.listen()
    }
    
    // MARK: - Sign In

    func signIn(_ email: String, _ password: String) -> AnyPublisher<AuthDataResult, Error> {
        return Future { promise in
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                if let error = error {
                    promise(.failure(error))
                } else if let authResult = authResult {
                    promise(.success(authResult))
                }
            }
        }.eraseToAnyPublisher()
    }

    // MARK: - Sign Up

    func signUp(_ email: String, _ password: String) -> AnyPublisher<AuthDataResult, Error> {
        return Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if let error = error {
                    promise(.failure(error))
                } else if let authResult = authResult {
                    promise(.success(authResult))
                }
            }
        }.eraseToAnyPublisher()
    }

    // MARK: - Sign Out

    func signOut() -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    // MARK: - State Changes

    private func listen_() -> AnyPublisher<Auth, Never> {
        return AuthStatePublisher().eraseToAnyPublisher()
    }
    
    private func listen() {
        authListener = self.listen_()
            .sink { completion in
                switch completion {
                case .finished:
                    print("Logging in")
                case .failure(let e):
                    print("Failed: \(e)")
                }
            } receiveValue: { [weak self] auth in
                self?.user = auth.currentUser
            }
    }
}
