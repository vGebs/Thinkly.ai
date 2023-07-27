//
//  LessonsDropDown.swift
//  Thinkly ai
//
//  Created by Vaughn on 2023-07-26.
//

import Foundation
import SwiftUI

struct LessonsDropDown: View {
    @Binding var lessons: [Lesson]
    @Binding var subunitNumber: Double
    @Binding var unitNumber: Int
    @ObservedObject var notesViewModel: NotesViewModel
    
    var body: some View {
        VStack {
            ForEach(lessons.indices, id: \.self) { i in
                HStack {
                    Image(systemName: "number.square")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                    
                    Text(lessons[i].lessonNumber)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if i == 0 {
                        Button(action: {
                            notesViewModel.trashLessons(with: unitNumber - 1, and: i)
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.buttonPrimary)
                        }
                    }
                }
                .padding(.top, 5)
                .padding(.bottom, 2)
                .padding(.leading, screenWidth * 0.05)
                .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    VStack {
                        Image(systemName: "book.closed")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.accent)
                        Spacer()
                    }
                    
                    Text("\(lessons[i].lessonTitle)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.leading, screenWidth * 0.05)
                .fixedSize(horizontal: false, vertical: true)
                
                Divider()
                    .padding(.leading, screenWidth * 0.035)
                
                HStack {
                    VStack {
                        Image(systemName: "note.text")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.accent)
                        Spacer()
                    }
                    
                    Text("\(lessons[i].lessonDescription)")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.leading, screenWidth * 0.05)
                .fixedSize(horizontal: false, vertical: true)
                
                Divider()
                    .padding(.leading, screenWidth * 0.035)
                
                if notesViewModel.submittedLessons.contains(subunitNumber) {
                    Button(action: {
                        notesViewModel.generateNotes(for: lessons[i].lessonNumber, unitNumber: unitNumber)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 3)
                                .foregroundColor(.buttonPrimary)
                            
                            HStack {
                                Image(systemName: "book")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.buttonPrimary)
                                
                                Text("Generate Notes")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                            }.padding()
                        }
                    }
                    .padding(.leading, screenWidth * 0.035)
                    
                    Divider()
                        .padding(.leading, screenWidth * 0.035)
                }
            }
            
            HStack {
                Button(action: {
                    notesViewModel.generateLessons(subunitNumber: subunitNumber)
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
                                .foregroundColor(.buttonPrimary)
                            
                            Text("Regenerate")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }.padding()
                    }
                }
                
                if !notesViewModel.submittedLessons.contains(subunitNumber) {
                    Button(action: {
                        notesViewModel.submitLessons(with: subunitNumber)
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
                                
                                Text("Submit")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                            }.padding()
                        }
                    }
                }
            }
            .padding(.leading, screenWidth * 0.035)
            
        }
    }
}
