//
//  LoadingView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-12.
//

import SwiftUI

struct LoadingView: View {
    @State private var shouldAnimate = false
    var body: some View {
        HStack {
            Circle()
                .fill(Color.primary)
                .frame(width: 20, height: 20)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever())
            Circle()
                .fill(Color.primary)
                .frame(width: 20, height: 20)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.3))
            Circle()
                .fill(Color.primary)
                .frame(width: 20, height: 20)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.6))
        }
        .onAppear {
            self.shouldAnimate = true
        }
        .onDisappear {
            shouldAnimate = false
        }
    }
}
