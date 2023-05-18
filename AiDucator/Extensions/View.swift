//
//  View.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func swipeGesture(offset: Binding<CGFloat>,action: @escaping () -> Void) -> _EndedGesture<_ChangedGesture<DragGesture>> {
        DragGesture()
            .onChanged { value in
                if value.translation.width > 0 {
                    offset.wrappedValue = value.translation.width
                }
            }
            .onEnded { value in
                let screenWidth = UIScreen.main.bounds.width
                let shouldDismiss = value.translation.width > screenWidth * 0.5
                let swipeSpeed = value.translation.width / value.time.timeIntervalSinceNow.magnitude
                let animationDuration = max(0.05, min(0.15, 500 / swipeSpeed))

                if shouldDismiss {
                    withAnimation(.easeOut(duration: animationDuration)) {
                        offset.wrappedValue = screenWidth
                    }
                    // Perform your navigation action for LandingView after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                        action()
                    }
                } else {
                    withAnimation {
                        offset.wrappedValue = .zero
                    }
                }
            }
    }
}
