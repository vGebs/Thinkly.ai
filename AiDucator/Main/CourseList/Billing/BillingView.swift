//
//  BillingView.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-08-23.
//

import Foundation
import SwiftUI

struct BillingView: View {
    
    @StateObject var viewModel = AppState.shared.billing
    @Binding var show: Bool
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            wave
            
            VStack {
                
                logo
                
                Text("Master your next skill with Thinkly Premium")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                
                Text("Generate a course suited to your needs!")
                    .font(.system(size: 27, weight: .heavy, design: .rounded))
                    .foregroundColor(.buttonPrimary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Button(action: {
                    if viewModel.products.count > 0 {
                        viewModel.purchase(product: viewModel.products[0])
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.black)
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 5)
                            .foregroundColor(.buttonPrimary)
                        
                        HStack {
                            Image(systemName: "lock.open")
                                .foregroundColor(.accent)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                            
                            Text("Unlock Premium")
                                .foregroundColor(.primary)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                    }
                }.frame(height: screenHeight * 0.07)
                
                Button(action: {
                    viewModel.restore()
                    show = false
                }) {
                    Text("Restore Purchases")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                }.padding()
            }
            .padding()
        }
    }
    
    var logo: some View {
        VStack {
            Image(systemName: "brain")
                .font(.system(size: 90, weight: .thin, design: .rounded))
                .foregroundColor(.accent)
                
            Text("Thinkly.ai")
                .font(.system(size: 30, weight: .black, design: .rounded)) //size 15
                .foregroundColor(.buttonPrimary)
        }
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

//var body: some View {
//    ZStack {
//        Color.black
//
//        VStack {
//            HStack {
//                Text("Products")
//                    .padding()
//
//                Spacer()
//
//                Button(action: {
//                    viewModel.restore()
//                }) {
//                    Text("Restore Purchases")
//                        .padding()
//                }
//            }
//            ScrollView {
//                ForEach(viewModel.products, id: \.self) { product in
//                    Text("Item name: \(product.localizedTitle)")
//                    Text("Price: $\(product.price)")
//
//                    Button(action: {
//                        viewModel.purchase(product)
//                    }) {
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(lineWidth: 3)
//                                .frame(width: 150, height: 20)
//                            Text("Purchase")
//                        }
//                    }
//                    Divider().padding(.bottom)
//                }
//            }
//        }
//
//    }.edgesIgnoringSafeArea(.all)
//}
