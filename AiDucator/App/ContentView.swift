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
                        .gesture(swipeGesture(action: {
                            appState.onLoginView = false
                            offset = .zero
                        }))
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                } else if appState.onSignupView {
                    SigninSignupView(viewModel: SigninSignupViewModel(mode: .signUp))
                        .frame(width: screenWidth, height: screenHeight * 0.95)
                        .offset(x: offset)
                        .gesture(swipeGesture(action: {
                            appState.onSignupView = false
                            offset = .zero
                        }))
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                }
            } else if appState.onMainView {
                ClassList()
            }
        }
    }
    
    func swipeGesture(action: @escaping () -> Void) -> _EndedGesture<_ChangedGesture<DragGesture>> {
        DragGesture()
            .onChanged { value in
                if value.translation.width > 0 {
                    self.offset = value.translation.width
                }
            }
            .onEnded { value in
                let screenWidth = UIScreen.main.bounds.width
                let shouldDismiss = value.translation.width > screenWidth * 0.5
                let swipeSpeed = value.translation.width / value.time.timeIntervalSinceNow.magnitude
                let animationDuration = max(0.05, min(0.15, 500 / swipeSpeed))

                if shouldDismiss {
                    withAnimation(.easeOut(duration: animationDuration)) {
                        self.offset = screenWidth
                    }
                    // Perform your navigation action for LandingView after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                        action()
                    }
                } else {
                    withAnimation {
                        self.offset = .zero
                    }
                }
            }
    }
}
