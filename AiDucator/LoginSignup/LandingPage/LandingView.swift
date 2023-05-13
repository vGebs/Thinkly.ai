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
            VStack {
                logoThreeHStack(opacity: $opacity, opacity2: $opacity2)
                Spacer()
                logoThreeHStackInverse(opacity: $opacity, opacity2: $opacity2)
                Spacer()
                logoThreeHStack(opacity: $opacity, opacity2: $opacity2)
                Spacer()
                logoThreeHStackInverse(opacity: $opacity, opacity2: $opacity2)
                Spacer()
                logoThreeHStack(opacity: $opacity, opacity2: $opacity2)
            }

            RoundedRectangle(cornerRadius: 40).stroke(lineWidth: 5)
                .foregroundColor(Color.accent)
                .frame(width: screenWidth - 1, height: screenHeight - 1)
                .edgesIgnoringSafeArea(.all)
            
            RoundedRectangle(cornerRadius: 23).stroke(lineWidth: 5)
                .foregroundColor(Color.accent)
                .frame(width: screenWidth * 0.56, height: screenHeight * 0.062)
                .offset(y: -screenHeight / 2)
            
            VStack{
                Image(systemName: "brain")
                    .font(.system(size: 90, weight: .thin, design: .rounded))
                    .foregroundColor(.primary)
                    
                Text("Thinkly.ai")
                    .font(.system(size: 30, weight: .black, design: .rounded)) //size 15
                    .foregroundColor(.buttonPrimary)
            }
            .offset(y: -screenHeight * 0.12)
            
            VStack {
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
                                .foregroundColor(Color.primary)
                            
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
                                .foregroundColor(Color.primary)
                            
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
            .offset(y: screenHeight * 0.33)
        }
        .preferredColorScheme(.dark)
    }
}

struct FlashingLogo: View {
    @Binding var opacity: Double
    var body: some View {
        Text("Thinkly.ai")
            .font(.system(size: 20, weight: .black, design: .rounded))
            .frame(width: 110, height: 40)
            .foregroundColor(Color.buttonPrimary)
            .opacity(opacity)
            .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true))
            .onAppear{
                opacity = 1
            }
    }
}

struct FlashingLogoInverse: View {
    @Binding var opacity: Double
    var body: some View {
        Text("Thinkly.ai")
            .font(.system(size: 20, weight: .black, design: .rounded))
            .frame(width: 110, height: 40)
            .foregroundColor(Color.primary)
            .opacity(opacity)
            .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true))
            .onAppear{
                opacity = 0
            }
    }
}

struct logoThreeHStack: View {
    @Binding var opacity: Double
    @Binding var opacity2: Double
    @State var posX = 0
    
    var body: some View {
        HStack {
            FlashingLogo(opacity: $opacity)
            Spacer()
            FlashingLogoInverse(opacity: $opacity2)
            Spacer()
            FlashingLogo(opacity: $opacity)
            Spacer()
            FlashingLogoInverse(opacity: $opacity2)
        }
        .frame(width: screenWidth * 1.2)
        .offset(x: CGFloat(posX))
        .animation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true))
        .onAppear{
            posX += 140
        }
    }
}

struct logoThreeHStackInverse: View {
    @Binding var opacity: Double
    @Binding var opacity2: Double
    @State var posX = 0
    
    var body: some View {
        HStack {
            FlashingLogoInverse(opacity: $opacity2)
            Spacer()
            FlashingLogo(opacity: $opacity)
            Spacer()
            FlashingLogoInverse(opacity: $opacity2)
            Spacer()
            FlashingLogo(opacity: $opacity)
        }
        .frame(width: screenWidth * 1.2)
        .offset(x: CGFloat(posX))
        .animation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true))
        .onAppear{
            posX -= 140
        }
    }
}
