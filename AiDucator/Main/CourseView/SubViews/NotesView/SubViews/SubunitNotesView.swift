//
//  SubunitNotesView.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-08-10.
//

import Foundation
import SwiftUI

struct SubunitNotesView: View {
    var unitIndex: Int
    var subunitIndex: Int
    @Binding var showNotes: Bool
    @ObservedObject var notesViewModel: NotesViewModel
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            wave
            VStack {
                ScrollView {
                    header
                    
                    Divider()
                    
                    VStack {
                        ForEach(notesViewModel.curriculum.units[unitIndex].subUnits![subunitIndex].lessons!.indices, id: \.self) { i in
                            HStack {
                                
                                Image(systemName: "note.text")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.accent)
                                
                                Text("\(notesViewModel.curriculum.units[unitIndex].subUnits![subunitIndex].lessons![i].lessonNumber) - \(notesViewModel.curriculum.units[unitIndex].subUnits![subunitIndex].lessons![i].lessonTitle)")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            
                            if notesViewModel.curriculum.units[unitIndex].subUnits![subunitIndex].lessons![i].notes == nil {
                                
                                if notesViewModel.loadingNotesNumbers.contains(notesViewModel.curriculum.units[unitIndex].subUnits![subunitIndex].lessons![i].lessonNumber) {
                                    LoadingView()
                                } else {
                                    Button(action: {
                                        notesViewModel.generateNotes(for: notesViewModel.curriculum.units[unitIndex].subUnits![subunitIndex].lessons![i].lessonNumber, unitIndex: unitIndex)
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(.black)
                                            
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(lineWidth: 3)
                                                .foregroundColor(.buttonPrimary)
                                            
                                            HStack {
                                                Image(systemName: "terminal")
                                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                                    .foregroundColor(.buttonPrimary)
                                                
                                                Text("Generate notes for lesson")
                                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                                    .foregroundColor(.primary)
                                            }.padding()
                                        }
                                    }
                                }
                                
                                Divider()
                                
                            } else {
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(.black)
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 3)
                                        .foregroundColor(.buttonPrimary)
                                    
                                    VStack {
                                        ForEach(notesViewModel.curriculum.units[unitIndex].subUnits![subunitIndex].lessons![i].notes!.notes.indices, id: \.self) { j in
                                            Text("")
                                            
                                            HStack {
                                                Text(notesViewModel.curriculum.units[unitIndex].subUnits![subunitIndex].lessons![i].notes!.notes[j].paragraph)
                                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                                    .foregroundColor(.primary)
                                                    .multilineTextAlignment(.leading)
                                                    .lineLimit(nil)  // Line breaks as needed
                                                    .fixedSize(horizontal: false, vertical: true)
                                                Spacer()
                                            }.padding(.horizontal)
                                            
                                            Text("")
                                        }
                                        
                                    }
                                }
                                
                                if !notesViewModel.submittedNotes.contains(notesViewModel.curriculum.units[unitIndex].subUnits![subunitIndex].lessons![i].lessonNumber) {
                                    Button(action: {
                                        let lessonNumber = notesViewModel.curriculum.units[unitIndex].subUnits![subunitIndex].lessons![i].lessonNumber
                                        let subunitNumber = notesViewModel.curriculum.units[unitIndex].subUnits![subunitIndex].unitNumber
                                        notesViewModel.submitNotes(unitIndex: unitIndex, subunitNumber: subunitNumber, lessonNumber: lessonNumber)
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
                                    }.padding(.top)
                                }
                                
                                Divider()
                                    .padding(.vertical)
                            }
                            
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                }
            }.padding(.top)
            
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: screenWidth / 6, height: screenHeight / 300)
                    .foregroundColor(.buttonPrimary)
                    .onTapGesture {
                        self.showNotes = false
                    }
                
                Spacer()
            }.padding(.top)
            
        }.edgesIgnoringSafeArea(.all)
    }
    
    var header: some View {
        HStack {
            VStack {
                Image(systemName: "note.text")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                
                Spacer()
            }
            
            VStack {
                Text("Notes: \(String(format: "%.1f", notesViewModel.curriculum.units[unitIndex].subUnits![subunitIndex].unitNumber)) - \(notesViewModel.curriculum.units[unitIndex].subUnits![subunitIndex].unitTitle)") //notes.notes[0].paragraph
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(nil)  // Line breaks as needed
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            Spacer()
            
            VStack {
                Button(action: {
                    showNotes = false
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.buttonPrimary)
                }
                .padding(.horizontal)
                
//                                Button(action: {
//                                    showNotes = false
//                                    notesViewModel.deleteNotes(unitIndex: unitIndex, subunitNumber: subunitNumber, lessonNumber: lessonNumber)
//                                }) {
//                                    Image(systemName: "trash")
//                                        .font(.system(size: 13, weight: .bold, design: .rounded))
//                                        .foregroundColor(.buttonPrimary)
//                                }
//                                .padding(.horizontal)
                
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
