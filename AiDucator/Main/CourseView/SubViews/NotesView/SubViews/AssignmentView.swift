//
//  AssignmentView.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-08-10.
//

import Foundation
import SwiftUI

struct AssignmentView: View {
    var unitIndex: Int
    var subunitIndex: Int
    var subunit: SubUnit
    @Binding var show: Bool
    @ObservedObject var notesViewModel: NotesViewModel
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            wave
            VStack {
                ScrollView {
                    header
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.black)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 3)
                            .foregroundColor(.buttonPrimary)
                        VStack {
                            ForEach(subunit.assignment!.questions, id: \.self) { question in
                                Text("")
                                
                                HStack {
                                    Text(question)
                                        .font(.system(size: 15, weight: .regular, design: .rounded))
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil)  // Line breaks as needed
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                }

                                Text("")
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    if !notesViewModel.submittedAssignments.contains(subunit.unitNumber) {
                        submitButton
                            .padding(.bottom)
                    }
                    
                    HStack {
                        regenerateButton
                        trashButton
                    }
                    .padding(.bottom)
                    .padding(.bottom)
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }
    
    var submitButton: some View {
        Button(action: {
            notesViewModel.submitAssignment(unitIndex: unitIndex, subunitIndex: subunitIndex)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.black)
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                
                HStack {
                    Image(systemName: "checkmark.square")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    
                    Text("Submit Notes")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }.padding()
            }
        }
        .padding(.horizontal)
    }
    
    var regenerateButton: some View {
        
        Button(action: {
            withAnimation {
                show = false
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.black)
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                
                HStack {
                    Image(systemName: "terminal")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    
                    Text("Regenerate")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }.padding()
            }
        }
        .padding(.leading)
    }
    
    var trashButton: some View {
        Button(action: {
            withAnimation {
                notesViewModel.deleteAssignment(unitIndex: unitIndex, subunitIndex: subunitIndex)
                show = false
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.black)
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                
                Image(systemName: "trash")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.buttonPrimary)
            }.frame(width: screenWidth / 6)
        }
        .padding(.trailing)
    }
    
    var header: some View {
        HStack {
            VStack {
                Image(systemName: "tray")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                
                Spacer()
            }
            
            VStack {
                Text("Assignment: \(subunit.unitTitle)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(nil)  // Line breaks as needed
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            
            Spacer()
            
            VStack {
                Button(action: {
                    show = false
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .padding(.top)
        .padding(.leading)
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
