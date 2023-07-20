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
                ScrollView(showsIndicators: false) {
                    
                    note
                        .padding()
                    
                    units
                        .padding(.bottom, screenHeight * 0.14)
                }
                .padding(.top, screenHeight * 0.155)
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
    
    var units: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.black)
            RoundedRectangle(cornerRadius: 15)
                .stroke(lineWidth: 3)
                .foregroundColor(.buttonPrimary)
            
            VStack {
                ForEach(viewModel.curriculum.units.indices, id: \.self) { index in
                    UnitDropDown(unit: $viewModel.curriculum.units[index], subunitsActive: true, loadingIndexes: $viewModel.loadingIndexes, generateSubUnits: {
                        viewModel.generateSubUnits(with: index)
                    })
                    .padding(index == viewModel.curriculum.units.count - 1 ? .bottom : [])
                    .padding(.top, index == 0 ? 5 : 0)
                    if index != viewModel.curriculum.units.count - 1 {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(height: 2)
                            .foregroundColor(.buttonPrimary)
                    }
                }
                .padding(.top, screenHeight * 0.01)
            }
        }
        .padding(.horizontal)
    }
}
