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
    @State private var offset: CGFloat = .zero
    
    var body: some View {
        ZStack {
            if !appState.onMainView {
                LandingView()
                    .opacity(appState.onLoginView || appState.onSignupView ? Double(min(1, offset / (UIScreen.main.bounds.width / 0.6))) : 1)

                if appState.onLoginView {
                    SigninSignupView(viewModel: SigninSignupViewModel(mode: .login))
                        .frame(width: screenWidth, height: screenHeight * 0.95)
                        .offset(x: offset)
                        .gesture(swipeGesture(offset: $offset, action: {
                            appState.onLoginView = false
                            offset = .zero
                        }))
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                } else if appState.onSignupView {
                    SigninSignupView(viewModel: SigninSignupViewModel(mode: .signUp))
                        .frame(width: screenWidth, height: screenHeight * 0.95)
                        .offset(x: offset)
                        .gesture(swipeGesture(offset: $offset, action: {
                            appState.onSignupView = false
                            offset = .zero
                        }))
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                }
            } else if appState.onMainView {
                MainView()
            }
        }
    }
}
