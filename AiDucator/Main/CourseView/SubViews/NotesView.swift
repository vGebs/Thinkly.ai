//
//  NotesView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import SwiftUI

struct NotesView: View {
    
    @StateObject var viewModel = NotesViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    if let user = AppState.shared.user {
                        if user.role == "teacher" {
                            addChapterButton
                            Divider()
                        }
                    }
                    
                    ForEach(viewModel.chapters) { chapter in
                        MyUnitsDropDown(chapter: chapter, popup: true)
                            .padding(.horizontal, 5)
                    }
                    .padding(.top, screenHeight * 0.01)
                }
                .frame(width: screenWidth)
                .padding(screenHeight * 0.12)
                
                Spacer()
            }
        }.frame(width: screenWidth, height: screenHeight)
    }
    
    var addChapterButton: some View {
        Button(action: {
            
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.black)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.buttonPrimary)
                
                HStack {
                    Image(systemName: "plus.app")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.accent)
                        .padding(.leading, 5)
                    
                    Text("Add Chapter")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding()
            }.padding(.top, 5)
            .frame(width: screenWidth * 0.9)
        }
    }
}


import Combine

//for this class we need to fetch all of the notes for that class.
//So for the course they are in, fetch all of the notes,

class NotesViewModel: ObservableObject {
    @Published var chapters: [Chapter] = [
        Chapter(title: "Intro", notes: [
            Note(title: "Intro to this course", content: ""),
            Note(title: "Sylabus", content: "")
        ]),
        Chapter(title: "Big stuff", notes: [
            Note(title: "This is the big stuff", content: "")
        ]),
        Chapter(title: "Final notes", notes: [
            Note(title: "Final info and shit", content: "")
        ])
    ]
}


struct MyUnitsDropDown: View {
    @State var expanded = false
    var chapter: Chapter
    var popup: Bool
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.black)
            RoundedRectangle(cornerRadius: 15)
                .stroke()
                .foregroundColor(.accent)

            VStack {
                unitPlaceholder
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.2)) {
                            expanded.toggle()
                        }
                    }
                
                if expanded && chapter.notes.count > 0 {
                    Divider()
                        .frame(width: screenWidth * 0.9)
                    
                    ForEach(chapter.notes) { note in
                        Button(action: {
                            //view note
                        }) {
                            HStack {
                                Image(systemName: "dot.square")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.accent)
                                
                                Text(note.title)
                                    .font(.system(size: 18, weight: .regular, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(.buttonPrimary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }.padding(.top)
                }
            }
        }
        .frame(width: screenWidth * 0.9)
    }
    
    var unitPlaceholder: some View {
        HStack {
            Image(systemName: "newspaper")
                .foregroundColor(.buttonPrimary)
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .padding(.horizontal)
            
            Text(chapter.title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            if chapter.notes.count > 0 {
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.buttonPrimary)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .padding(.trailing)
            } else {
                Button(action: {
                    // Action to add note
                }) {
                    Image(systemName: "plus.app")
                        .foregroundColor(.buttonPrimary)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .padding(.trailing)
                }
            }
        }
        .padding(.vertical)
    }
}
