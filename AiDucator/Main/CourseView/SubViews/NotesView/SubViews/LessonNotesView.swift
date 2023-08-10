//
//  LessonNotesView.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-07-27.
//

import Foundation
import SwiftUI

struct LessonNotesView: View {
    @Binding var notes: Notes?
    @Binding var showNotes: Bool 
    @ObservedObject var notesViewModel: NotesViewModel
    var unitIndex: Int
    var subunitNumber: Double
    var lessonNumber: String
    
    var body: some View {
        
        if let notes = notes {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                wave
                
                ScrollView {
                    VStack {
                        HStack {
                            VStack {
                                Image(systemName: "note.text")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.accent)
                                
                                Spacer()
                            }
                            
                            VStack {
                                Text(notes.notes[0].paragraph)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .lineLimit(nil)  // Line breaks as needed
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                            }
                            Spacer()
                            
                            VStack {
                                Button(action: {
                                    showNotes = false
                                    notesViewModel.deleteNotes(unitIndex: unitIndex, subunitNumber: subunitNumber, lessonNumber: lessonNumber)
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(.buttonPrimary)
                                }
                                .padding(.horizontal)
                                
                                Spacer()
                            }
                        }
                        .padding(.top)
                        .padding(.leading)
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 3)
                                .foregroundColor(.buttonPrimary)
                            VStack {
                                ForEach(notes.notes.indices, id: \.self) { i in
                                    if i > 0 {
                                        HStack {
                                            Text(notes.notes[i].paragraph)
                                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(nil)  // Line breaks as needed
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer()
                                        }
                                    }
                                    Text("")
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        if !notesViewModel.submittedNotes.contains(lessonNumber) {
                            Button(action: {
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
                                            .foregroundColor(.buttonPrimary)
                                        
                                        Text("Submit Notes")
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                    }.padding()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                            .padding(.bottom)
                        }
                    }
                }.edgesIgnoringSafeArea(.all)
            }
            
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
                
                VStack {
                    Spacer()
                    
                    Image(systemName: "brain")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(Color.black)
                    
                    Text("Thinkly.ai")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(Color.buttonPrimary)
                }
                .frame(width: screenWidth, height: screenHeight * 0.85)
            }
        }
    }
}
