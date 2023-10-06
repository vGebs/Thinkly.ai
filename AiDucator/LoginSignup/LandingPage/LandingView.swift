//
//  LandingView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-11.
//

import Foundation
import SwiftUI

struct LandingView: View {
    @State var opacity: Double = 0
    @State var opacity2: Double = 1
    
    @StateObject var viewModel = LandingViewModel()
    
    var body: some View {
        ZStack{
            Color.black.edgesIgnoringSafeArea(.all)
            wave
            
            VStack {
                Spacer()
                
                Image(systemName: "brain")
                    .font(.system(size: 90, weight: .regular, design: .rounded))
                    .foregroundColor(.accent)
                    
                Text("Thinkly.ai")
                    .font(.system(size: 35, weight: .black, design: .rounded)) //size 15
                    .foregroundColor(.primary)
                
                Spacer()
                
                signupButton
                
                loginButton
            }
            .padding(.bottom, screenHeight * 0.05)
        }
        .preferredColorScheme(.dark)
    }
    
    var signupButton: some View {
        Button(action: {
            withAnimation {
                viewModel.signupPressed()
            }
        }){
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .edgesIgnoringSafeArea(.all)
                
                RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                    .edgesIgnoringSafeArea(.all)
                
                HStack {
                    Spacer()
                    Image(systemName: "newspaper")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    
                    Text("Sign up")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                }
            }
        }
        .frame(width: screenWidth * 0.6, height: screenHeight * 0.1)
        .foregroundColor(.black)
        .padding(.bottom)
    }
    
    var loginButton: some View {
        Button(action: {
            withAnimation {
                viewModel.loginPressed()
            }
        }){
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .edgesIgnoringSafeArea(.all)
                
                RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                    .edgesIgnoringSafeArea(.all)
                
                HStack {
                    Spacer()
                    Image(systemName: "lock")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    
                    Text("Log in")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                }
            }
        }
        .frame(width: screenWidth * 0.6, height: screenHeight * 0.1)
        .foregroundColor(.black)
    }
    
    @State private var phase = AnimatableData(phase: 0)
    @State private var phase1 = AnimatableData(phase: 45)
    @State private var phase2 = AnimatableData(phase: 90)
    
    var wave: some View {
        ZStack {
            VStack {
                Spacer()
                SineWave(frequency: 0.3, amplitude: 0.035, phase: phase)
                    .fill(Color.accent)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                            phase.phase += 1
                        }
                    }
            }
            
            VStack {
                Spacer()
                SineWave(frequency: 0.5, amplitude: 0.03, phase: phase1)
                    .fill(Color.buttonPrimary)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                            phase1.phase += 1
                        }
                    }
            }.offset(y: 130)
            
            ZStack {
                VStack {
                    Spacer()
                    SineWave(frequency: 0.5, amplitude: 0.025, phase: phase2)
                        .fill(Color.primary)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                                phase2.phase += 1
                            }
                        }
                }.offset(y: 200)
                
//                VStack {
//                    Spacer()
//
//                    Image(systemName: "brain")
//                        .font(.system(size: 20, weight: .black, design: .rounded))
//                        .foregroundColor(Color.black)
//
//                    Text("Thinkly.ai")
//                        .font(.system(size: 20, weight: .black, design: .rounded))
//                        .foregroundColor(Color.buttonPrimary)
//                }
//                .frame(width: screenWidth, height: screenHeight * 0.85)
            }
        }
    }
}
