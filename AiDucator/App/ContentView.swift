//
//  ContentView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-08.
//

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        ZStack {
            if appState.onLandingView {
                LandingView()
            } else if appState.onLoginView {
                SigninSignupView(viewModel: SigninSignupViewModel(mode: .login))
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                
            } else if appState.onSignupView {
                SigninSignupView(viewModel: SigninSignupViewModel(mode: .signUp))
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
            } else if appState.onMainView {
                ClassList()
            }
        }
    }
}
