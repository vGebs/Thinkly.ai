//
//  NotesView.swift
//  AiDucator
//
//  Created by Vaughn on 2023-05-18.
//

import SwiftUI

struct NotesView: View {

    @StateObject var viewModel: NotesViewModel
    
    var body: some View {
        ZStack {
            VStack {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 1, height: 1)
                    .opacity(0)
                    .padding(.top, screenHeight * 0.1)
                
                ScrollView {
                    
                    note
                        .padding()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.black)
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 3)
                            .foregroundColor(.buttonPrimary)
                        
                        VStack {
                            ForEach(viewModel.curriculum.units.indices, id: \.self) { index in
                                WeeklyTopicDropDown(topic: $viewModel.curriculum.units[index])
                                    .padding(index == viewModel.curriculum.units.count - 1 ? .bottom : [])
                                
                                if index != viewModel.curriculum.units.count - 1 {
                                    Divider()
                                }
                            }
                            .padding(.top, screenHeight * 0.01)
                        }
                    }
                    .padding(.horizontal)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 1, height: 1)
                        .opacity(0)
                        .padding(.bottom, screenHeight * 0.12)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: screenWidth, height: screenHeight)
    }
    
    var note: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.black)
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 3)
                .foregroundColor(.accent)
            
            HStack {
                Image(systemName: "note.text")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.accent)
                
                Text("Press the drop-down button on each unit to show the generate sub-units button")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.primary)
            }.padding(.vertical)
        }
    }
}
