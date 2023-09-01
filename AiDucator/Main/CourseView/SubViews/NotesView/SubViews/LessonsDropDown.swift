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
    
    @State private var showNotes = false
    @State var notes: Notes? = nil
    @State var lessonNumber = ""
    
    @State var showPremiumOffer = false
    
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
                    
                    if i == 0 && !notesViewModel.subunitHasNotes(unitIndex: unitNumber - 1, subunitNumber: subunitNumber) && notesViewModel.loadingNotesNumbers.isEmpty{
                        Button(action: {
                            notesViewModel.trashLessons(with: unitNumber - 1, and: subunitNumber)
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
                
                if notesViewModel.submittedLessons.contains(subunitNumber) && !notesViewModel.lessonHasNotes(unitIndex: unitNumber - 1, subunitNumber: subunitNumber, lessonNumber: lessons[i].lessonNumber) && !notesViewModel.loadingNotesNumbers.contains(lessons[i].lessonNumber){
                    Button(action: {
                        if AppState.shared.billing.entitlementManager.hasPro {
                            notesViewModel.generateNotes(for: lessons[i].lessonNumber, unitIndex: unitNumber - 1)
                        } else {
                            showPremiumOffer = true
                        }
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
                } else if notesViewModel.lessonHasNotes(unitIndex: unitNumber - 1, subunitNumber: subunitNumber, lessonNumber: lessons[i].lessonNumber) {
                    Button(action: {
                        self.showNotes = true
                        self.notes = lessons[i].notes
                        self.lessonNumber = lessons[i].lessonNumber
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 3)
                                .foregroundColor(.buttonPrimary)
                            
                            HStack {
                                Image(systemName: "binoculars")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.buttonPrimary)
                                
                                Text("View Notes")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                            }.padding()
                        }
                    }
                    .padding(.leading, screenWidth * 0.035)
                    
                    if !notesViewModel.submittedNotes.contains(lessons[i].lessonNumber) {
                        Button(action: {
                            notesViewModel.submitNotes(unitIndex: unitNumber - 1, subunitNumber: subunitNumber, lessonNumber: lessons[i].lessonNumber)
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
                        .padding(.leading, screenWidth * 0.035)
                    }
                    
                    Divider()
                        .padding(.leading, screenWidth * 0.035)
                } else if notesViewModel.loadingNotesNumbers.contains(lessons[i].lessonNumber) {
                    LoadingView()
                    
                    Divider()
                        .padding(.leading, screenWidth * 0.035)
                }
            }
            
            if !notesViewModel.subunitHasNotes(unitIndex: unitNumber - 1, subunitNumber: subunitNumber) {
                VStack {
                    Button(action: {
                        if AppState.shared.billing.entitlementManager.hasPro {
                            notesViewModel.generateLessons(subunitNumber: subunitNumber)
                        } else {
                            showPremiumOffer = false
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
            
        }.sheet(isPresented: $showNotes) {
            LessonNotesView(notes: $notes, showNotes: $showNotes, notesViewModel: notesViewModel, unitIndex: unitNumber - 1, subunitNumber: subunitNumber, lessonNumber: lessonNumber)
        }
        .sheet(isPresented: $showPremiumOffer) {
            BillingView(show: $showPremiumOffer)
        }
    }
}
